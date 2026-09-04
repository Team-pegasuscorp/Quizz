## Profile tab page. Edit this script and `scenes/tabs/profile_tab.tscn` only.
extends Control

const ProfileSnapshot = preload("res://scripts/profile/profile_snapshot.gd")
const UiTokens = preload("res://scripts/config/ui_tokens.gd")
const UiStyle = preload("res://scripts/config/ui_style.gd")
const PressScaleUtil = preload("res://scripts/ui/press_scale.gd")

const _FEATURED_BADGE_IDS: Array[String] = [
	"unbeatable",
	"scientist",
	"serious",
	"expert_level",
]
const _CATEGORY_ICONS := {
	"sport": "🏆",
	"cinema": "🎬",
	"history": "📜",
}

@onready var hero_panel: PanelContainer = %HeroPanel
@onready var avatar_frame: PanelContainer = %AvatarFrame
@onready var avatar_texture: TextureRect = %AvatarTexture
@onready var pseudo_input: LineEdit = %PseudoInput
@onready var verified_badge: Label = %VerifiedBadge
@onready var rank_label: Label = %RankLabel
@onready var edit_avatar_button: Button = %EditAvatarButton
@onready var xp_panel: PanelContainer = %XpPanel
@onready var level_label: Label = %LevelLabel
@onready var xp_bar: ProgressBar = %XpBar
@onready var xp_caption_label: Label = %XpCaptionLabel
@onready var xp_next_label: Label = %XpNextLabel
@onready var demo_hint_label: Label = %DemoHintLabel
@onready var profile_status_label: Label = %ProfileStatusLabel
@onready var stats_grid: GridContainer = %StatsGrid
@onready var categories_list: VBoxContainer = %CategoriesList
@onready var see_all_button: Button = %SeeAllButton
@onready var badges_grid: GridContainer = %BadgesGrid
@onready var history_list: VBoxContainer = %HistoryList
@onready var photo_dialog: FileDialog = %PhotoDialog
@onready var badge_backdrop: ColorRect = %BadgeBackdrop
@onready var badge_detail_panel: PanelContainer = %BadgeDetailPanel
@onready var badge_detail_icon: Label = %BadgeDetailIcon
@onready var badge_detail_title: Label = %BadgeDetailTitle
@onready var badge_detail_desc: Label = %BadgeDetailDesc
@onready var badge_detail_close: Button = %BadgeDetailClose

var _profile_data: Dictionary = {}
var _animated_nodes: Array[Control] = []
var _xp_tween: Tween
var _show_all_categories: bool = false


func _ready() -> void:
	pseudo_input.max_length = UiTokens.MAX_PLAYER_NAME_LENGTH
	_style_chrome()
	_wire_events()
	_apply_translations()
	refresh()


func refresh() -> void:
	_profile_data = ProfileSnapshot.build_full(LocaleManager.get_content_locale())
	_populate_identity()
	_populate_xp()
	_populate_stats()
	_populate_categories()
	_populate_badges()
	_populate_history()
	_play_entrance_animation()


func on_tab_shown() -> void:
	refresh()


func _style_chrome() -> void:
	hero_panel.add_theme_stylebox_override("panel", UiStyle.profile_hero())
	xp_panel.add_theme_stylebox_override("panel", UiStyle.profile_soft_card(UiTokens.PROFILE_HERO))
	avatar_frame.add_theme_stylebox_override(
		"panel",
		UiStyle.filled_disc(Color.WHITE, int(UiTokens.PROFILE_AVATAR_DISPLAY * 0.5))
	)
	var edit_style := UiStyle.filled_disc(Color.WHITE, 22)
	edit_style.shadow_size = 8
	edit_avatar_button.add_theme_stylebox_override("normal", edit_style)
	edit_avatar_button.add_theme_stylebox_override("hover", edit_style)
	edit_avatar_button.add_theme_stylebox_override("pressed", edit_style)
	edit_avatar_button.add_theme_color_override("font_color", UiTokens.PROFILE_HERO)
	var empty := StyleBoxEmpty.new()
	pseudo_input.add_theme_stylebox_override("normal", empty)
	pseudo_input.add_theme_stylebox_override("focus", empty)
	pseudo_input.add_theme_stylebox_override("read_only", empty)
	badge_detail_panel.add_theme_stylebox_override("panel", UiStyle.profile_soft_card(UiTokens.PROFILE_HERO))
	see_all_button.add_theme_color_override("font_color", UiTokens.PROFILE_HERO)
	see_all_button.add_theme_color_override("font_hover_color", UiTokens.PROFILE_HERO)
	see_all_button.add_theme_color_override("font_pressed_color", UiTokens.PROFILE_HERO)


func _wire_events() -> void:
	edit_avatar_button.pressed.connect(_on_change_photo_pressed)
	photo_dialog.file_selected.connect(_on_photo_file_selected)
	photo_dialog.files_selected.connect(_on_photo_selected)
	pseudo_input.text_submitted.connect(_on_pseudo_submitted)
	pseudo_input.focus_exited.connect(_on_pseudo_focus_exited)
	see_all_button.pressed.connect(_on_see_all_pressed)
	badge_backdrop.gui_input.connect(_on_badge_backdrop_gui_input)
	badge_detail_close.pressed.connect(_close_badge_detail)
	LocaleManager.locale_changed.connect(_on_locale_changed)
	PressScaleUtil.wire(edit_avatar_button, self)
	PressScaleUtil.wire(see_all_button, self)
	PressScaleUtil.wire(badge_detail_close, self)


func _apply_translations() -> void:
	pseudo_input.placeholder_text = tr("UI_PROFILE_PSEUDO_PLACEHOLDER")
	edit_avatar_button.tooltip_text = tr("UI_PROFILE_EDIT_AVATAR")
	verified_badge.tooltip_text = tr("UI_PROFILE_VERIFIED")
	see_all_button.text = tr("UI_PROFILE_SEE_ALL")
	badge_detail_close.text = tr("UI_BACK")
	%StatsTitle.text = tr("UI_PROFILE_STATS_TITLE")
	%CategoriesTitle.text = tr("UI_PROFILE_CATEGORIES_TITLE")
	%BadgesTitle.text = tr("UI_PROFILE_BADGES_TITLE")
	%HistoryTitle.text = tr("UI_PROFILE_HISTORY_TITLE")


func _populate_identity() -> void:
	pseudo_input.text = _profile_data.get("player_name", UiTokens.DEFAULT_PLAYER_NAME)
	avatar_texture.texture = _profile_data.get("avatar_texture")
	rank_label.text = tr(_profile_data.get("rank_title_key", "UI_RANK_ROOKIE"))
	demo_hint_label.visible = _profile_data.get("is_demo", false)
	demo_hint_label.text = tr("UI_PROFILE_DEMO_HINT")


func _populate_xp() -> void:
	var xp_now: int = int(_profile_data.get("xp", 0))
	var xp_next: int = int(_profile_data.get("xp_to_next", 100))
	var remaining: int = int(_profile_data.get("xp_remaining", maxi(xp_next - xp_now, 0)))
	level_label.text = tr("UI_PLAYER_LEVEL").format({"level": _profile_data.get("level", 1)})
	xp_caption_label.text = tr("UI_PROFILE_XP_PROGRESS").format({
		"current": _format_count(xp_now),
		"target": _format_count(xp_next),
	})
	xp_next_label.text = tr("UI_PROFILE_XP_NEXT").format({"xp": _format_count(remaining)})
	xp_bar.max_value = maxf(float(xp_next), 1.0)
	xp_bar.add_theme_stylebox_override("background", UiStyle.progress_bg())
	xp_bar.add_theme_stylebox_override("fill", UiStyle.progress_fill(UiTokens.PROFILE_HERO))
	_animate_xp_bar(float(xp_now))
	_animated_nodes.append(xp_panel)


func _populate_stats() -> void:
	_clear_container(stats_grid)
	var stats := [
		{
			"icon": "🎮",
			"label": tr("UI_PROFILE_GAMES_PLAYED"),
			"value": _format_count(int(_profile_data.get("games_played", 0))),
			"accent": UiTokens.ACCENT_QUIZ,
		},
		{
			"icon": "🏆",
			"label": tr("UI_PROFILE_WINS"),
			"value": _format_count(int(_profile_data.get("wins", 0))),
			"accent": UiTokens.FEEDBACK_CORRECT,
		},
		{
			"icon": "✕",
			"label": tr("UI_PROFILE_LOSSES"),
			"value": _format_count(int(_profile_data.get("losses", 0))),
			"accent": UiTokens.FEEDBACK_WRONG,
		},
		{
			"icon": "📈",
			"label": tr("UI_PROFILE_WIN_RATE"),
			"value": "%.0f %%" % _profile_data.get("win_rate_percent", 0.0),
			"accent": UiTokens.ACCENT_HOME,
		},
		{
			"icon": "🔥",
			"label": tr("UI_PROFILE_BEST_STREAK"),
			"value": _format_count(int(_profile_data.get("best_win_streak", 0))),
			"accent": UiTokens.ACCENT_LEADERBOARD,
		},
		{
			"icon": "⭐",
			"label": tr("UI_PROFILE_BEST_SCORE"),
			"value": _format_count(int(_profile_data.get("best_score", 0))),
			"accent": UiTokens.ACCENT_PROFILE,
		},
	]
	for stat in stats:
		var card := _make_stat_card(
			str(stat.get("icon", "")),
			str(stat.get("label", "")),
			str(stat.get("value", "")),
			stat.get("accent", UiTokens.INK)
		)
		stats_grid.add_child(card)
		_animated_nodes.append(card)


func _populate_categories() -> void:
	_clear_container(categories_list)
	var categories: Array = _profile_data.get("categories", [])
	if categories.is_empty():
		categories_list.add_child(_make_empty_label(tr("UI_PROFILE_NO_CATEGORIES")))
		see_all_button.visible = false
		return
	see_all_button.visible = true
	var limit := categories.size() if _show_all_categories or categories.size() <= 3 else 3
	for index in range(limit):
		var card := _make_category_card(categories[index])
		categories_list.add_child(card)
		_animated_nodes.append(card)


func _populate_badges() -> void:
	_clear_container(badges_grid)
	var featured: Array = []
	for achievement in _profile_data.get("achievements", []):
		if str(achievement.get("id", "")) in _FEATURED_BADGE_IDS:
			featured.append(achievement)
	for achievement in featured:
		var badge := _make_badge_button(achievement)
		badges_grid.add_child(badge)
		_animated_nodes.append(badge)


func _populate_history() -> void:
	_clear_container(history_list)
	var history: Array = _profile_data.get("history", [])
	if history.is_empty():
		history_list.add_child(_make_empty_label(tr("UI_PROFILE_NO_HISTORY")))
		return
	for row in history:
		var card := _make_history_card(row)
		history_list.add_child(card)
		_animated_nodes.append(card)


func _make_stat_card(icon: String, caption: String, value: String, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 108)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", UiStyle.profile_soft_card(accent))

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var icon_chip := Label.new()
	icon_chip.text = icon
	icon_chip.add_theme_font_size_override("font_size", 18)
	icon_chip.add_theme_color_override("font_color", accent)
	vbox.add_child(icon_chip)

	var caption_label := Label.new()
	caption_label.text = caption
	caption_label.add_theme_font_size_override("font_size", 12)
	caption_label.add_theme_color_override("font_color", UiTokens.INK_MUTED)
	vbox.add_child(caption_label)

	var value_label := Label.new()
	value_label.text = value
	value_label.add_theme_font_size_override("font_size", 26)
	value_label.add_theme_color_override("font_color", UiTokens.INK)
	vbox.add_child(value_label)
	return panel


func _make_category_card(row: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	var category_id := str(row.get("id", ""))
	var accent := UiTokens.accent_for_category(category_id)
	panel.add_theme_stylebox_override("panel", UiStyle.profile_soft_card(accent))

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)

	var icon_wrap := PanelContainer.new()
	icon_wrap.custom_minimum_size = Vector2(44, 44)
	icon_wrap.add_theme_stylebox_override("panel", UiStyle.chip(accent))
	hbox.add_child(icon_wrap)
	var icon_label := Label.new()
	icon_label.text = str(_CATEGORY_ICONS.get(category_id, "📘"))
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 18)
	icon_wrap.add_child(icon_label)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 6)
	hbox.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)
	var name_label := Label.new()
	name_label.text = str(row.get("name", ""))
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", UiTokens.INK)
	header.add_child(name_label)
	var percent := Label.new()
	percent.text = "%.0f %%" % row.get("accuracy_percent", 0.0)
	percent.add_theme_font_size_override("font_size", 15)
	percent.add_theme_color_override("font_color", accent)
	header.add_child(percent)

	var bar := ProgressBar.new()
	bar.custom_minimum_size.y = 8
	bar.max_value = 100.0
	bar.value = row.get("accuracy_percent", 0.0)
	bar.show_percentage = false
	bar.add_theme_stylebox_override("background", UiStyle.progress_bg())
	bar.add_theme_stylebox_override("fill", UiStyle.progress_fill(accent))
	vbox.add_child(bar)

	var meta := Label.new()
	meta.text = tr("UI_PROFILE_CATEGORY_GAMES").format({"games": row.get("games_played", 0)})
	meta.add_theme_font_size_override("font_size", 12)
	meta.add_theme_color_override("font_color", UiTokens.INK_MUTED)
	vbox.add_child(meta)
	return panel


func _make_badge_button(achievement: Dictionary) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(72, 96)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var unlocked: bool = achievement.get("unlocked", false)
	var accent := UiTokens.PROFILE_HERO if unlocked else UiTokens.INK_MUTED
	button.add_theme_stylebox_override("normal", UiStyle.profile_soft_card(accent))
	button.add_theme_stylebox_override("hover", UiStyle.profile_soft_card(accent))
	button.add_theme_stylebox_override("pressed", UiStyle.profile_soft_card(accent))
	button.modulate = Color.WHITE if unlocked else Color(1, 1, 1, 0.55)
	button.text = "%s\n%s" % [
		str(achievement.get("icon", "?")),
		tr(str(achievement.get("title_key", ""))),
	]
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_color_override("font_color", UiTokens.INK if unlocked else UiTokens.INK_MUTED)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.pressed.connect(_on_badge_pressed.bind(achievement))
	PressScaleUtil.wire(button, self)
	return button


func _make_history_card(row: Dictionary) -> PanelContainer:
	var won: bool = row.get("won", false)
	var accent := UiTokens.FEEDBACK_CORRECT if won else UiTokens.FEEDBACK_WRONG
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiStyle.profile_soft_card(accent))

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)

	var avatar := PanelContainer.new()
	avatar.custom_minimum_size = Vector2(44, 44)
	avatar.add_theme_stylebox_override("panel", UiStyle.filled_disc(accent, 22))
	hbox.add_child(avatar)
	var initial := Label.new()
	var opponent := str(row.get("opponent_name", "")).strip_edges()
	initial.text = opponent.substr(0, 1).to_upper() if not opponent.is_empty() else "Q"
	initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	initial.add_theme_color_override("font_color", Color.WHITE)
	initial.add_theme_font_size_override("font_size", 16)
	avatar.add_child(initial)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	hbox.add_child(info)

	var title := Label.new()
	title.text = (
		tr("UI_PROFILE_VS").format({"name": opponent})
		if not opponent.is_empty()
		else tr("UI_PROFILE_SOLO")
	)
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", UiTokens.INK)
	info.add_child(title)

	var category := Label.new()
	category.text = str(row.get("category_name", ""))
	category.add_theme_font_size_override("font_size", 12)
	category.add_theme_color_override("font_color", UiTokens.INK_MUTED)
	info.add_child(category)

	var result_col := VBoxContainer.new()
	result_col.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(result_col)
	var result := Label.new()
	result.text = tr("UI_PROFILE_VICTORY") if won else tr("UI_PROFILE_DEFEAT")
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	result.add_theme_font_size_override("font_size", 12)
	result.add_theme_color_override("font_color", accent)
	result_col.add_child(result)
	var score := Label.new()
	score.text = _format_count(int(row.get("score", 0)))
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score.add_theme_font_size_override("font_size", 18)
	score.add_theme_color_override("font_color", UiTokens.INK)
	result_col.add_child(score)
	return panel


func _make_empty_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", UiTokens.INK_MUTED)
	return label


func _clear_container(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func _format_count(value: int) -> String:
	var raw := str(absi(value))
	var grouped := ""
	var count := 0
	for index in range(raw.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			grouped = " " + grouped
		grouped = raw[index] + grouped
		count += 1
	if value < 0:
		return "-" + grouped
	return grouped


func _animate_xp_bar(target: float) -> void:
	if _xp_tween != null and _xp_tween.is_valid():
		_xp_tween.kill()
	xp_bar.value = 0.0
	_xp_tween = create_tween()
	_xp_tween.tween_property(xp_bar, "value", target, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _play_entrance_animation() -> void:
	var delay := 0.0
	for node in _animated_nodes:
		if not is_instance_valid(node):
			continue
		node.modulate.a = 0.0
		var start_y := node.position.y + 10.0
		var end_y := node.position.y
		node.position.y = start_y
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(node, "modulate:a", 1.0, 0.2).set_delay(delay)
		tween.tween_property(node, "position:y", end_y, 0.2).set_delay(delay)
		delay += 0.025
	_animated_nodes.clear()


func _on_see_all_pressed() -> void:
	_show_all_categories = not _show_all_categories
	_populate_categories()


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


func _save_player_name() -> void:
	var next_name := pseudo_input.text
	if next_name.strip_edges() == SaveManager.player_name:
		return
	SaveManager.set_player_name(next_name)
	profile_status_label.text = tr("UI_PROFILE_SAVED")


func _on_change_photo_pressed() -> void:
	photo_dialog.popup_centered_ratio(0.8)


func _on_photo_file_selected(path: String) -> void:
	_on_photo_selected(PackedStringArray([path]))


func _on_photo_selected(paths: PackedStringArray) -> void:
	if paths.is_empty():
		return
	if SaveManager.set_profile_avatar_from_file(paths[0]):
		profile_status_label.text = ""
		refresh()
	else:
		profile_status_label.text = tr("UI_WRONG")


func _on_pseudo_submitted(_new_text: String) -> void:
	_save_player_name()


func _on_pseudo_focus_exited() -> void:
	_save_player_name()


func _on_locale_changed(_locale: String) -> void:
	_apply_translations()
	refresh()
