## BrainUp profile — layout and tiles matching the competitive mock.
extends Control

const ProfileSnapshot = preload("res://scripts/profile/profile_snapshot.gd")
const ProfileDonutScript = preload("res://scripts/ui/profile_donut.gd")
const UiTokens = preload("res://scripts/config/ui_tokens.gd")
const UiStyle = preload("res://scripts/config/ui_style.gd")
const PressScaleUtil = preload("res://scripts/ui/press_scale.gd")
const ScenePaths = preload("res://scripts/config/scene_paths.gd")

@onready var sections: VBoxContainer = %Sections
@onready var photo_dialog: FileDialog = %PhotoDialog
@onready var badge_backdrop: ColorRect = %BadgeBackdrop
@onready var badge_detail_panel: PanelContainer = %BadgeDetailPanel
@onready var badge_detail_icon: Label = %BadgeDetailIcon
@onready var badge_detail_title: Label = %BadgeDetailTitle
@onready var badge_detail_desc: Label = %BadgeDetailDesc
@onready var badge_detail_close: Button = %BadgeDetailClose
@onready var edit_backdrop: ColorRect = %EditBackdrop
@onready var edit_panel: PanelContainer = %EditPanel
@onready var edit_title: Label = %EditTitle
@onready var pseudo_input: LineEdit = %PseudoInput
@onready var change_photo_button: Button = %ChangePhotoButton
@onready var remove_photo_button: Button = %RemovePhotoButton
@onready var edit_save_button: Button = %EditSaveButton
@onready var edit_close_button: Button = %EditCloseButton

var _profile_data: Dictionary = {}
var _animated_nodes: Array[Control] = []
var _xp_bar: ProgressBar
var _active_tweens: Array[Tween] = []


func _ready() -> void:
	pseudo_input.max_length = UiTokens.MAX_PLAYER_NAME_LENGTH
	badge_detail_panel.add_theme_stylebox_override("panel", UiStyle.profile_card(UiTokens.ACCENT_PROFILE, true))
	edit_panel.add_theme_stylebox_override("panel", UiStyle.profile_card(UiTokens.ACCENT_PROFILE, true))
	_style_dark_controls()
	_wire_events()
	_apply_translations()
	refresh()


func _style_dark_controls() -> void:
	for label in [edit_title, badge_detail_title, badge_detail_icon]:
		if label:
			label.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT)
	badge_detail_desc.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT_MUTED)
	pseudo_input.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT)
	pseudo_input.add_theme_color_override("font_placeholder_color", UiTokens.PROFILE_TEXT_MUTED)
	for button in [
		change_photo_button, remove_photo_button, edit_save_button,
		edit_close_button, badge_detail_close,
	]:
		_style_profile_button(button, UiTokens.ACCENT_PROFILE)


func refresh() -> void:
	_profile_data = ProfileSnapshot.build_full(LocaleManager.get_content_locale())
	_rebuild_sections()
	_play_entrance_animation()


func on_tab_shown() -> void:
	refresh()


func _wire_events() -> void:
	change_photo_button.pressed.connect(_on_change_photo_pressed)
	remove_photo_button.pressed.connect(_on_remove_photo_pressed)
	photo_dialog.files_selected.connect(_on_photo_selected)
	edit_save_button.pressed.connect(_on_edit_save_pressed)
	edit_close_button.pressed.connect(_close_edit_profile)
	edit_backdrop.gui_input.connect(_on_edit_backdrop_gui_input)
	pseudo_input.text_submitted.connect(func(_t: String) -> void: _on_edit_save_pressed())
	badge_backdrop.gui_input.connect(_on_badge_backdrop_gui_input)
	badge_detail_close.pressed.connect(_close_badge_detail)
	LocaleManager.locale_changed.connect(_on_locale_changed)
	for button in [
		change_photo_button, remove_photo_button, edit_save_button,
		edit_close_button, badge_detail_close,
	]:
		PressScaleUtil.wire(button, self)


func _apply_translations() -> void:
	edit_title.text = tr("UI_PROFILE_EDIT")
	pseudo_input.placeholder_text = tr("UI_PROFILE_PSEUDO_PLACEHOLDER")
	change_photo_button.text = tr("UI_PROFILE_CHANGE_PHOTO")
	remove_photo_button.text = tr("UI_PROFILE_REMOVE_PHOTO")
	edit_save_button.text = tr("UI_PROFILE_SAVE")
	edit_close_button.text = tr("UI_BACK")
	badge_detail_close.text = tr("UI_BACK")


func _rebuild_sections() -> void:
	_kill_profile_tweens()
	_animated_nodes.clear()
	while sections.get_child_count() > 0:
		var child := sections.get_child(0)
		sections.remove_child(child)
		child.free()

	sections.add_theme_constant_override("separation", 12)
	sections.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	## Mobile-first: one clean vertical stack (no overlapping 2-col grid).
	sections.add_child(_build_hero())
	sections.add_child(_build_stats_strip())
	sections.add_child(_build_categories_tile())
	sections.add_child(_build_best_subject_tile())
	sections.add_child(_build_win_distribution_tile())
	sections.add_child(_build_history_tile())
	sections.add_child(_build_badges_tile())
	sections.add_child(_build_world_rank_tile())
	sections.add_child(_build_season_tile())


func _kill_profile_tweens() -> void:
	for tween in _active_tweens:
		if tween != null and tween.is_valid():
			tween.kill()
	_active_tweens.clear()


func _track_tween(tween: Tween) -> Tween:
	_active_tweens.append(tween)
	return tween


func _build_hero() -> PanelContainer:
	var panel := _tile(UiTokens.ACCENT_PROFILE, true)
	var margin := _pad(14, 14)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)

	## Avatar
	var avatar_frame := PanelContainer.new()
	avatar_frame.custom_minimum_size = Vector2(UiTokens.PROFILE_AVATAR_DISPLAY, UiTokens.PROFILE_AVATAR_DISPLAY)
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = UiTokens.PROFILE_CARD_BG_RAISED
	frame_style.set_corner_radius_all(int(UiTokens.PROFILE_AVATAR_DISPLAY * 0.5))
	frame_style.set_border_width_all(3)
	frame_style.border_color = UiTokens.PROFILE_AVATAR_RING
	frame_style.shadow_size = 16
	frame_style.shadow_color = Color(UiTokens.ACCENT_PROFILE.r, UiTokens.ACCENT_PROFILE.g, UiTokens.ACCENT_PROFILE.b, 0.4)
	frame_style.content_margin_left = 5
	frame_style.content_margin_top = 5
	frame_style.content_margin_right = 5
	frame_style.content_margin_bottom = 5
	avatar_frame.add_theme_stylebox_override("panel", frame_style)
	row.add_child(avatar_frame)

	var avatar_btn := Button.new()
	avatar_btn.flat = true
	avatar_btn.focus_mode = Control.FOCUS_NONE
	avatar_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	avatar_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	avatar_btn.pressed.connect(_open_edit_profile)
	avatar_frame.add_child(avatar_btn)

	var avatar := TextureRect.new()
	avatar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.texture = _profile_data.get("avatar_texture")
	avatar_btn.add_child(avatar)

	## Identity + XP
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 6)
	row.add_child(info)

	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 6)
	info.add_child(name_row)

	var name_label := Label.new()
	name_label.text = str(_profile_data.get("player_name", UiTokens.DEFAULT_PLAYER_NAME))
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT)
	name_row.add_child(name_label)

	var verified := Label.new()
	verified.text = "✓"
	verified.add_theme_font_size_override("font_size", 16)
	verified.add_theme_color_override("font_color", Color(0.36, 0.75, 1.0, 1))
	name_row.add_child(verified)

	var country := Label.new()
	country.text = "🇫🇷  %s" % str(_profile_data.get("country", "France"))
	country.add_theme_font_size_override("font_size", 12)
	country.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT_MUTED)
	info.add_child(country)

	var level_row := HBoxContainer.new()
	level_row.add_theme_constant_override("separation", 8)
	info.add_child(level_row)

	var star := Label.new()
	star.text = "★"
	star.add_theme_font_size_override("font_size", 18)
	star.add_theme_color_override("font_color", UiTokens.ACCENT_PROFILE)
	level_row.add_child(star)

	var level := Label.new()
	level.text = tr("UI_PLAYER_LEVEL").format({"level": _profile_data.get("level", 1)}).to_upper()
	level.add_theme_font_size_override("font_size", 13)
	level.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT)
	level_row.add_child(level)

	_xp_bar = ProgressBar.new()
	_xp_bar.custom_minimum_size.y = 10
	_xp_bar.max_value = 1.0
	_xp_bar.value = 0.0
	_xp_bar.show_percentage = false
	_xp_bar.add_theme_stylebox_override("background", UiStyle.profile_progress_bg())
	_xp_bar.add_theme_stylebox_override("fill", UiStyle.progress_fill(UiTokens.ACCENT_PROFILE))
	info.add_child(_xp_bar)

	var xp_line := Label.new()
	xp_line.text = "XP %s / %s" % [
		_format_int(int(_profile_data.get("xp", 0))),
		_format_int(int(_profile_data.get("xp_to_next", 100))),
	]
	xp_line.add_theme_font_size_override("font_size", 11)
	xp_line.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT_MUTED)
	info.add_child(xp_line)

	var next_xp := Label.new()
	next_xp.text = tr("UI_PROFILE_XP_TO_NEXT").format({"xp": _format_int(int(_profile_data.get("xp_remaining", 0)))})
	next_xp.add_theme_font_size_override("font_size", 11)
	next_xp.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT_MUTED)
	info.add_child(next_xp)

	## League diamond card
	var ranking: Dictionary = _profile_data.get("ranking", {})
	var league := _tile(UiTokens.ACCENT_PROFILE, true)
	league.custom_minimum_size = Vector2(108, 0)
	row.add_child(league)
	var league_pad := _pad(10, 12)
	league.add_child(league_pad)
	var league_col := VBoxContainer.new()
	league_col.alignment = BoxContainer.ALIGNMENT_CENTER
	league_col.add_theme_constant_override("separation", 4)
	league_pad.add_child(league_col)

	var diamond := Label.new()
	diamond.text = "💎"
	diamond.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	diamond.add_theme_font_size_override("font_size", 34)
	league_col.add_child(diamond)

	var league_title := Label.new()
	league_title.text = tr("UI_PROFILE_LEAGUE").to_upper()
	league_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	league_title.add_theme_font_size_override("font_size", 9)
	league_title.add_theme_color_override("font_color", UiTokens.PROFILE_TITLE_CAPS)
	league_col.add_child(league_title)

	var league_name := Label.new()
	league_name.text = tr(str(ranking.get("league_key", "UI_RANK_ROOKIE"))).to_upper()
	league_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	league_name.add_theme_font_size_override("font_size", 11)
	league_name.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT)
	league_col.add_child(league_name)

	var points := Label.new()
	points.text = "🏆 %s" % _format_int(int(ranking.get("points", 0)))
	points.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	points.add_theme_font_size_override("font_size", 13)
	points.add_theme_color_override("font_color", UiTokens.ACCENT_LEADERBOARD)
	league_col.add_child(points)

	_animated_nodes.append(panel)
	call_deferred("_animate_xp_bar")
	return panel


func _build_stats_strip() -> PanelContainer:
	var panel := _tile()
	var margin := _pad(8, 10)
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	margin.add_child(row)

	var ranking: Dictionary = _profile_data.get("ranking", {})
	var items := [
		{"icon": "🎮", "value": _format_int(int(_profile_data.get("games_played", 0))), "label": tr("UI_PROFILE_GAMES_PLAYED"), "color": Color(0.36, 0.75, 1.0)},
		{"icon": "🏆", "value": _format_int(int(_profile_data.get("wins", 0))), "label": tr("UI_PROFILE_WINS"), "color": UiTokens.FEEDBACK_CORRECT},
		{"icon": "◎", "value": "%.0f%%" % _profile_data.get("win_rate_percent", 0.0), "label": tr("UI_PROFILE_WIN_RATE"), "color": UiTokens.ACCENT_LEADERBOARD},
		{"icon": "🔥", "value": str(_profile_data.get("best_win_streak", 0)), "label": tr("UI_PROFILE_BEST_STREAK"), "color": Color(1.0, 0.42, 0.28)},
		{"icon": "📊", "value": _format_int(int(ranking.get("points", 0))), "label": tr("UI_PROFILE_RANKING_TITLE"), "color": UiTokens.ACCENT_PROFILE},
	]
	for item in items:
		row.add_child(_stat_icon_cell(item.icon, str(item.value), str(item.label), item.color))

	_animated_nodes.append(panel)
	return panel


func _stat_icon_cell(icon: String, value: String, label: String, color: Color) -> Control:
	var cell := VBoxContainer.new()
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cell.alignment = BoxContainer.ALIGNMENT_CENTER
	cell.add_theme_constant_override("separation", 2)

	var icon_label := Label.new()
	icon_label.text = icon
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 18)
	cell.add_child(icon_label)

	var value_label := Label.new()
	value_label.text = value
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_font_size_override("font_size", 15)
	value_label.add_theme_color_override("font_color", color)
	cell.add_child(value_label)

	var caption := Label.new()
	caption.text = label.to_upper()
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_font_size_override("font_size", 8)
	caption.add_theme_color_override("font_color", UiTokens.PROFILE_TITLE_CAPS)
	cell.add_child(caption)
	return cell


func _build_categories_tile() -> PanelContainer:
	var panel := _tile()
	var root := _tile_body(panel, tr("UI_PROFILE_CATEGORIES_MASTERED"))
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 10)
	root.add_child(list)

	var categories: Array = _profile_data.get("categories", [])
	var shown := 0
	for row in categories:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		if int(row.get("games_played", 0)) <= 0 and not _profile_data.get("is_demo", false):
			continue
		list.add_child(_category_mastery_row(row))
		shown += 1
	if shown == 0:
		list.add_child(_empty(tr("UI_PROFILE_NO_CATEGORIES")))
	_animated_nodes.append(panel)
	return panel


func _category_mastery_row(row: Dictionary) -> Control:
	var accent := UiTokens.accent_for_category(str(row.get("id", "")))
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)

	var icon_wrap := PanelContainer.new()
	icon_wrap.custom_minimum_size = Vector2(36, 36)
	var icon_style := StyleBoxFlat.new()
	icon_style.bg_color = Color(accent.r, accent.g, accent.b, 0.22)
	icon_style.set_corner_radius_all(18)
	icon_wrap.add_theme_stylebox_override("panel", icon_style)
	hbox.add_child(icon_wrap)
	var icon := Label.new()
	icon.text = str(row.get("icon", "🧠"))
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 16)
	icon_wrap.add_child(icon)

	var mid := VBoxContainer.new()
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.add_theme_constant_override("separation", 4)
	hbox.add_child(mid)

	var title := Label.new()
	title.text = str(row.get("name", ""))
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT)
	mid.add_child(title)

	var bar := ProgressBar.new()
	bar.custom_minimum_size.y = 7
	bar.max_value = 1.0
	bar.value = float(row.get("mastery_progress", 0.0))
	bar.show_percentage = false
	bar.add_theme_stylebox_override("background", UiStyle.profile_progress_bg())
	bar.add_theme_stylebox_override("fill", UiStyle.progress_fill(accent))
	mid.add_child(bar)

	var right := VBoxContainer.new()
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(right)

	var level := Label.new()
	level.text = tr("UI_PLAYER_LEVEL").format({"level": row.get("display_level", row.get("mastery_level", 1))})
	level.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	level.add_theme_font_size_override("font_size", 10)
	level.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT_MUTED)
	right.add_child(level)

	var medal := Label.new()
	medal.text = _medal_icon(str(row.get("medal", "none")))
	medal.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	medal.add_theme_font_size_override("font_size", 16)
	right.add_child(medal)
	return hbox


func _build_best_subject_tile() -> PanelContainer:
	var panel := _tile(UiTokens.FEEDBACK_CORRECT)
	var root := _tile_body(panel, tr("UI_PROFILE_BEST_SUBJECT"))
	var best: Dictionary = _profile_data.get("best_category", {})
	if best.is_empty():
		root.add_child(_empty(tr("UI_PROFILE_NO_CATEGORIES")))
		_animated_nodes.append(panel)
		return panel

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	root.add_child(row)

	var icon := Label.new()
	icon.text = str(best.get("icon", "🧠"))
	icon.add_theme_font_size_override("font_size", 36)
	row.add_child(icon)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 2)
	row.add_child(col)

	var name_label := Label.new()
	name_label.text = str(best.get("name", ""))
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT)
	col.add_child(name_label)

	var level := Label.new()
	level.text = tr("UI_PLAYER_LEVEL").format({"level": best.get("display_level", best.get("mastery_level", 1))})
	level.add_theme_font_size_override("font_size", 12)
	level.add_theme_color_override("font_color", UiTokens.FEEDBACK_CORRECT)
	col.add_child(level)

	var acc := Label.new()
	acc.text = tr("UI_PROFILE_BEST_SUBJECT_ACC").format({"percent": "%.0f" % best.get("accuracy_percent", 0.0)})
	acc.add_theme_font_size_override("font_size", 11)
	acc.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT_MUTED)
	col.add_child(acc)

	_animated_nodes.append(panel)
	return panel


func _build_win_distribution_tile() -> PanelContainer:
	var panel := _tile(UiTokens.ACCENT_PROFILE)
	var root := _tile_body(panel, tr("UI_PROFILE_WIN_SPLIT"))
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	root.add_child(body)

	var donut := ProfileDonutScript.new()
	donut.custom_minimum_size = Vector2(96, 96)
	body.add_child(donut)

	var dist: Array = _profile_data.get("win_distribution", [])
	var segments: Array = []
	for row in dist:
		segments.append({"ratio": row.get("ratio", 0.0), "color": row.get("color", Color.WHITE)})
	donut.set_segments(segments, tr("UI_PROFILE_WINS_COUNT").format({"count": _profile_data.get("wins", 0)}))

	var legend := VBoxContainer.new()
	legend.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	legend.add_theme_constant_override("separation", 4)
	body.add_child(legend)
	for row in dist:
		var line := Label.new()
		line.text = "%s  %d%%" % [row.get("name", ""), row.get("percent", 0)]
		line.add_theme_font_size_override("font_size", 11)
		line.add_theme_color_override("font_color", row.get("color", UiTokens.PROFILE_TEXT))
		legend.add_child(line)

	_animated_nodes.append(panel)
	return panel


func _build_history_tile() -> PanelContainer:
	var panel := _tile()
	var root := _tile_body(panel, tr("UI_PROFILE_HISTORY_TITLE"))
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 8)
	root.add_child(list)

	var history: Array = _profile_data.get("history", [])
	if history.is_empty():
		list.add_child(_empty(tr("UI_PROFILE_NO_HISTORY")))
	else:
		var count := 0
		for row in history:
			if count >= 4:
				break
			list.add_child(_history_row(row))
			count += 1
	_animated_nodes.append(panel)
	return panel


func _history_row(row: Dictionary) -> Control:
	var won: bool = row.get("won", false)
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)

	var avatar := PanelContainer.new()
	avatar.custom_minimum_size = Vector2(32, 32)
	var av_style := StyleBoxFlat.new()
	av_style.bg_color = UiTokens.PROFILE_CARD_BG_RAISED
	av_style.set_corner_radius_all(16)
	avatar.add_theme_stylebox_override("panel", av_style)
	hbox.add_child(avatar)
	var initial := Label.new()
	initial.text = str(row.get("opponent", "?"))[0].to_upper()
	initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	initial.add_theme_font_size_override("font_size", 13)
	initial.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT)
	avatar.add_child(initial)

	var mid := VBoxContainer.new()
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.add_theme_constant_override("separation", 1)
	hbox.add_child(mid)

	var name_label := Label.new()
	name_label.text = str(row.get("opponent", ""))
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT)
	mid.add_child(name_label)

	var meta := Label.new()
	meta.text = "%s · %s" % [row.get("category_name", ""), _format_age(int(row.get("age_hours", 0)))]
	meta.add_theme_font_size_override("font_size", 10)
	meta.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT_MUTED)
	mid.add_child(meta)

	var right := VBoxContainer.new()
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(right)

	var result := Label.new()
	result.text = tr("UI_PROFILE_WIN") if won else tr("UI_PROFILE_LOSS")
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	result.add_theme_font_size_override("font_size", 11)
	result.add_theme_color_override("font_color", UiTokens.FEEDBACK_CORRECT if won else UiTokens.FEEDBACK_WRONG)
	right.add_child(result)

	var score := Label.new()
	score.text = "%d - %d" % [row.get("correct_count", 0), row.get("total_count", 0)]
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score.add_theme_font_size_override("font_size", 11)
	score.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT_MUTED)
	right.add_child(score)
	return hbox


func _build_badges_tile() -> PanelContainer:
	var panel := _tile(UiTokens.ACCENT_LEADERBOARD)
	var root := _tile_body(panel, tr("UI_PROFILE_BADGES_RECENT"))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	root.add_child(grid)

	var achievements: Array = _profile_data.get("achievements", [])
	var limit := mini(achievements.size(), 6)
	for i in range(limit):
		grid.add_child(_badge_cell(achievements[i]))
	_animated_nodes.append(panel)
	return panel


func _badge_cell(achievement: Dictionary) -> Button:
	var unlocked: bool = achievement.get("unlocked", false)
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 72)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var accent := UiTokens.ACCENT_LEADERBOARD if unlocked else UiTokens.PROFILE_TEXT_MUTED
	button.add_theme_stylebox_override("normal", UiStyle.profile_card(accent))
	button.add_theme_stylebox_override("hover", UiStyle.profile_card(accent, true))
	button.add_theme_stylebox_override("pressed", UiStyle.profile_card(accent))
	button.modulate = Color.WHITE if unlocked else UiTokens.PROFILE_BADGE_LOCKED
	button.text = "%s\n%s" % [str(achievement.get("icon", "?")), tr(str(achievement.get("title_key", "")))]
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT)
	button.clip_text = true
	button.pressed.connect(_on_badge_pressed.bind(achievement))
	return button


func _build_world_rank_tile() -> PanelContainer:
	var panel := _tile(UiTokens.ACCENT_PROFILE, true)
	var root := _tile_body(panel, tr("UI_PROFILE_WORLD_RANK"))
	var ranking: Dictionary = _profile_data.get("ranking", {})

	var rank := Label.new()
	rank.text = "#%s" % _format_int(int(ranking.get("rank", 0)))
	rank.add_theme_font_size_override("font_size", 28)
	rank.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT)
	root.add_child(rank)

	var top := Label.new()
	var percentile := 8 if _profile_data.get("is_demo", false) else clampi(100 - int(ranking.get("rank", 100)), 1, 99)
	top.text = tr("UI_PROFILE_TOP_PERCENT").format({"percent": percentile})
	top.add_theme_font_size_override("font_size", 13)
	top.add_theme_color_override("font_color", UiTokens.ACCENT_PROFILE)
	root.add_child(top)

	var spark := Label.new()
	spark.text = "📈  · · · · ·"
	spark.add_theme_font_size_override("font_size", 18)
	spark.add_theme_color_override("font_color", Color(UiTokens.ACCENT_PROFILE.r, UiTokens.ACCENT_PROFILE.g, UiTokens.ACCENT_PROFILE.b, 0.85))
	root.add_child(spark)

	var btn := Button.new()
	btn.text = tr("UI_PROFILE_SEE_LEADERBOARD")
	_style_profile_button(btn, UiTokens.ACCENT_PROFILE)
	btn.pressed.connect(_open_leaderboard)
	PressScaleUtil.wire(btn, self)
	root.add_child(btn)

	_animated_nodes.append(panel)
	return panel


func _build_season_tile() -> PanelContainer:
	var panel := _tile(UiTokens.ACCENT_LEADERBOARD, true)
	var root := _tile_body(panel, tr("UI_PROFILE_BEST_SEASON"))
	var season: Dictionary = _profile_data.get("season", {})

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	root.add_child(row)

	var crest := Label.new()
	crest.text = "🏅"
	crest.add_theme_font_size_override("font_size", 42)
	row.add_child(crest)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 3)
	row.add_child(col)

	var season_label := Label.new()
	season_label.text = tr("UI_PROFILE_SEASON_N").format({"n": season.get("number", 1)}).to_upper()
	season_label.add_theme_font_size_override("font_size", 12)
	season_label.add_theme_color_override("font_color", UiTokens.ACCENT_LEADERBOARD)
	col.add_child(season_label)

	var pts := Label.new()
	pts.text = "%s pts" % _format_int(int(season.get("points", 0)))
	pts.add_theme_font_size_override("font_size", 16)
	pts.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT)
	col.add_child(pts)

	var meta := Label.new()
	meta.text = tr("UI_PROFILE_SEASON_META").format({
		"wins": season.get("wins", 0),
		"rate": "%.0f" % season.get("win_rate", 0.0),
	})
	meta.add_theme_font_size_override("font_size", 11)
	meta.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT_MUTED)
	col.add_child(meta)

	_animated_nodes.append(panel)
	return panel


func _tile(accent: Color = Color(0, 0, 0, 0), raised: bool = false) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	panel.add_theme_stylebox_override("panel", UiStyle.profile_card(accent, raised))
	return panel


func _tile_body(panel: PanelContainer, title_text: String) -> VBoxContainer:
	var margin := _pad(12, 12)
	panel.add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)
	var title := Label.new()
	title.text = title_text.to_upper()
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", UiTokens.PROFILE_TITLE_CAPS)
	root.add_child(title)
	return root


func _pad(h: int, v: int) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", h)
	margin.add_theme_constant_override("margin_right", h)
	margin.add_theme_constant_override("margin_top", v)
	margin.add_theme_constant_override("margin_bottom", v)
	return margin


func _empty(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT_MUTED)
	return label


func _medal_icon(medal: String) -> String:
	match medal:
		"gold":
			return "🥇"
		"silver":
			return "🥈"
		"bronze":
			return "🥉"
		_:
			return "▫️"


func _format_int(value: int) -> String:
	var raw := str(absi(value))
	var out := ""
	var count := 0
	for i in range(raw.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			out = " " + out
		out = raw[i] + out
		count += 1
	return ("-" if value < 0 else "") + out


func _format_age(hours: int) -> String:
	if hours <= 0:
		return tr("UI_PROFILE_TIME_NOW")
	if hours < 24:
		return tr("UI_PROFILE_TIME_HOURS").format({"hours": hours})
	return tr("UI_PROFILE_TIME_DAYS").format({"days": int(hours / 24.0)})


func _style_profile_button(button: Button, accent: Color) -> void:
	if button == null:
		return
	var normal := UiStyle.profile_card(accent)
	normal.bg_color = Color(accent.r, accent.g, accent.b, 0.28)
	var hover := UiStyle.profile_card(accent, true)
	hover.bg_color = Color(accent.r, accent.g, accent.b, 0.4)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", normal)
	button.add_theme_color_override("font_color", UiTokens.PROFILE_TEXT)


func _animate_xp_bar() -> void:
	if _xp_bar == null or not is_instance_valid(_xp_bar):
		return
	var target := clampf(float(_profile_data.get("xp_progress", 0.0)), 0.0, 1.0)
	_xp_bar.value = 0.0
	var tween := _track_tween(create_tween())
	tween.tween_property(_xp_bar, "value", target, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _play_entrance_animation() -> void:
	## Only fade — never touch position (breaks VBox layout / causes overlap).
	var delay := 0.0
	for node in _animated_nodes:
		if not is_instance_valid(node):
			continue
		node.modulate.a = 0.0
		var tween := _track_tween(create_tween())
		tween.tween_property(node, "modulate:a", 1.0, 0.2).set_delay(delay)
		delay += 0.025
	_animated_nodes.clear()


func _open_leaderboard() -> void:
	var shell := get_tree().current_scene
	if shell == null:
		return
	var page := ScenePaths.page_index_for_tab(ScenePaths.Tab.LEADERBOARD)
	if shell.has_node("%TabSwipeContainer"):
		shell.get_node("%TabSwipeContainer").set_tab(page, true)
	if shell.has_node("%BottomNavBar"):
		shell.get_node("%BottomNavBar").set_active_tab(page)


func _open_edit_profile() -> void:
	pseudo_input.text = str(_profile_data.get("player_name", ""))
	remove_photo_button.visible = _profile_data.get("has_custom_avatar", false)
	edit_backdrop.visible = true
	edit_panel.visible = true
	edit_panel.move_to_front()
	pseudo_input.grab_focus()


func _close_edit_profile() -> void:
	edit_backdrop.visible = false
	edit_panel.visible = false


func _on_edit_save_pressed() -> void:
	SaveManager.set_player_name(pseudo_input.text)
	_close_edit_profile()
	refresh()


func _on_edit_backdrop_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_close_edit_profile()


func _on_badge_pressed(achievement: Dictionary) -> void:
	badge_detail_icon.text = str(achievement.get("icon", "?"))
	badge_detail_title.text = tr(str(achievement.get("title_key", "")))
	badge_detail_desc.text = tr(str(achievement.get("desc_key", "")))
	if not achievement.get("unlocked", false):
		badge_detail_desc.text += "\n\n" + tr("UI_PROFILE_BADGE_LOCKED")
	badge_backdrop.visible = true
	badge_detail_panel.visible = true
	badge_detail_panel.move_to_front()


func _close_badge_detail() -> void:
	badge_backdrop.visible = false
	badge_detail_panel.visible = false


func _on_badge_backdrop_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_close_badge_detail()


func _on_change_photo_pressed() -> void:
	photo_dialog.popup_centered_ratio(0.8)


func _on_remove_photo_pressed() -> void:
	SaveManager.clear_profile_avatar()
	remove_photo_button.visible = false
	refresh()
	_open_edit_profile()


func _on_photo_selected(paths: PackedStringArray) -> void:
	if paths.is_empty():
		return
	if SaveManager.set_profile_avatar_from_file(paths[0]):
		refresh()
		_open_edit_profile()


func _on_locale_changed(_locale: String) -> void:
	_apply_translations()
	refresh()
