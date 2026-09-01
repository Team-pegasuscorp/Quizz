extends Control

const ProfileSnapshot = preload("res://scripts/profile/profile_snapshot.gd")
const UiTokens = preload("res://scripts/config/ui_tokens.gd")
const PressScaleUtil = preload("res://scripts/ui/press_scale.gd")

@onready var content_vbox: VBoxContainer = %ContentVBox
@onready var hero_panel: PanelContainer = %HeroPanel
@onready var avatar_texture: TextureRect = %AvatarTexture
@onready var pseudo_input: LineEdit = %PseudoInput
@onready var rank_label: Label = %RankLabel
@onready var level_label: Label = %LevelLabel
@onready var xp_bar: ProgressBar = %XpBar
@onready var xp_caption_label: Label = %XpCaptionLabel
@onready var demo_hint_label: Label = %DemoHintLabel
@onready var change_photo_button: Button = %ChangePhotoButton
@onready var remove_photo_button: Button = %RemovePhotoButton
@onready var profile_status_label: Label = %ProfileStatusLabel
@onready var stats_grid: GridContainer = %StatsGrid
@onready var categories_list: VBoxContainer = %CategoriesList
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


func _ready() -> void:
	pseudo_input.max_length = UiTokens.MAX_PLAYER_NAME_LENGTH
	_wire_events()
	_apply_translations()
	refresh()


func refresh() -> void:
	_profile_data = ProfileSnapshot.build_full(LocaleManager.get_content_locale())
	_populate_identity()
	_populate_stats()
	_populate_categories()
	_populate_badges()
	_populate_history()
	_play_entrance_animation()


func _wire_events() -> void:
	change_photo_button.pressed.connect(_on_change_photo_pressed)
	remove_photo_button.pressed.connect(_on_remove_photo_pressed)
	photo_dialog.files_selected.connect(_on_photo_selected)
	pseudo_input.text_submitted.connect(_on_pseudo_submitted)
	pseudo_input.focus_exited.connect(_on_pseudo_focus_exited)
	badge_backdrop.gui_input.connect(_on_badge_backdrop_gui_input)
	badge_detail_close.pressed.connect(_close_badge_detail)
	LocaleManager.locale_changed.connect(_on_locale_changed)
	PressScaleUtil.wire(change_photo_button, self)
	PressScaleUtil.wire(remove_photo_button, self)
	PressScaleUtil.wire(badge_detail_close, self)


func _apply_translations() -> void:
	pseudo_input.placeholder_text = tr("UI_PROFILE_PSEUDO_PLACEHOLDER")
	change_photo_button.text = tr("UI_PROFILE_CHANGE_PHOTO")
	remove_photo_button.text = tr("UI_PROFILE_REMOVE_PHOTO")
	badge_detail_close.text = tr("UI_BACK")
	%StatsTitle.text = tr("UI_PROFILE_STATS_TITLE")
	%CategoriesTitle.text = tr("UI_PROFILE_CATEGORIES_TITLE")
	%BadgesTitle.text = tr("UI_PROFILE_BADGES_TITLE")
	%HistoryTitle.text = tr("UI_PROFILE_HISTORY_TITLE")


func _populate_identity() -> void:
	pseudo_input.text = _profile_data.get("player_name", UiTokens.DEFAULT_PLAYER_NAME)
	avatar_texture.texture = _profile_data.get("avatar_texture")
	remove_photo_button.visible = _profile_data.get("has_custom_avatar", false)
	rank_label.text = tr(_profile_data.get("rank_title_key", "UI_RANK_ROOKIE"))
	level_label.text = tr("UI_PLAYER_LEVEL").format({"level": _profile_data.get("level", 1)})
	xp_bar.max_value = _profile_data.get("xp_to_next", 100)
	xp_bar.value = _profile_data.get("xp", 0)
	xp_bar.add_theme_stylebox_override("background", _bar_bg_style())
	xp_bar.add_theme_stylebox_override("fill", _bar_fill_style())
	xp_caption_label.text = tr("UI_PROFILE_XP_PROGRESS").format({
		"current": _profile_data.get("xp", 0),
		"target": _profile_data.get("xp_to_next", 100),
	})
	demo_hint_label.visible = _profile_data.get("is_demo", false)
	demo_hint_label.text = tr("UI_PROFILE_DEMO_HINT")


func _populate_stats() -> void:
	_clear_container(stats_grid)
	var stats := [
		{"label": tr("UI_PROFILE_GAMES_PLAYED"), "value": str(_profile_data.get("games_played", 0)), "accent": UiTokens.NEUTRAL},
		{"label": tr("UI_PROFILE_WINS"), "value": str(_profile_data.get("wins", 0)), "accent": UiTokens.FEEDBACK_CORRECT},
		{"label": tr("UI_PROFILE_LOSSES"), "value": str(_profile_data.get("losses", 0)), "accent": UiTokens.FEEDBACK_WRONG},
		{"label": tr("UI_PROFILE_WIN_RATE"), "value": "%.0f%%" % _profile_data.get("win_rate_percent", 0.0), "accent": UiTokens.PROFILE_STAT_ACCENT},
		{"label": tr("UI_PROFILE_CORRECT_ANSWERS"), "value": str(_profile_data.get("correct_answers", 0)), "accent": UiTokens.NEUTRAL},
		{"label": tr("UI_PROFILE_WIN_STREAK"), "value": str(_profile_data.get("current_win_streak", 0)), "accent": UiTokens.FEEDBACK_CORRECT},
		{"label": tr("UI_PROFILE_BEST_STREAK"), "value": str(_profile_data.get("best_win_streak", 0)), "accent": UiTokens.PROFILE_STAT_ACCENT},
		{"label": tr("UI_PROFILE_BEST_SCORE"), "value": str(_profile_data.get("best_score", 0)), "accent": UiTokens.PROFILE_STAT_ACCENT},
	]
	for stat in stats:
		var card := _make_stat_card(stat.get("label", ""), stat.get("value", ""), stat.get("accent", UiTokens.NEUTRAL))
		stats_grid.add_child(card)
		_animated_nodes.append(card)


func _populate_categories() -> void:
	_clear_container(categories_list)
	var categories: Array = _profile_data.get("categories", [])
	if categories.is_empty():
		categories_list.add_child(_make_empty_label(tr("UI_PROFILE_NO_CATEGORIES")))
		return
	for row in categories:
		var card := _make_category_card(row)
		categories_list.add_child(card)
		_animated_nodes.append(card)


func _populate_badges() -> void:
	_clear_container(badges_grid)
	for achievement in _profile_data.get("achievements", []):
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


func _make_stat_card(caption: String, value: String, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(150, 88)
	panel.add_theme_stylebox_override("panel", _card_style())

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	var value_label := Label.new()
	value_label.text = value
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_font_size_override("font_size", 22)
	value_label.add_theme_color_override("font_color", accent)
	vbox.add_child(value_label)

	var caption_label := Label.new()
	caption_label.text = caption
	caption_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption_label.add_theme_font_size_override("font_size", 11)
	caption_label.add_theme_color_override("font_color", UiTokens.TAB_INACTIVE_COLOR)
	vbox.add_child(caption_label)

	return panel


func _make_category_card(row: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _card_style())

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)

	var name_label := Label.new()
	name_label.text = str(row.get("name", ""))
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", UiTokens.PROFILE_STAT_ACCENT)
	header.add_child(name_label)

	var mastery_label := Label.new()
	mastery_label.text = tr(str(row.get("mastery_label_key", "UI_MASTERY_0")))
	mastery_label.add_theme_font_size_override("font_size", 12)
	mastery_label.add_theme_color_override("font_color", UiTokens.FEEDBACK_CORRECT)
	header.add_child(mastery_label)

	var meta := Label.new()
	meta.text = tr("UI_PROFILE_CATEGORY_META").format({
		"games": row.get("games_played", 0),
		"accuracy": "%.0f" % row.get("accuracy_percent", 0.0),
	})
	meta.add_theme_font_size_override("font_size", 13)
	meta.add_theme_color_override("font_color", UiTokens.TAB_INACTIVE_COLOR)
	vbox.add_child(meta)

	var bar := ProgressBar.new()
	bar.custom_minimum_size.y = 10
	bar.max_value = 1.0
	bar.value = row.get("mastery_progress", 0.0)
	bar.show_percentage = false
	bar.add_theme_stylebox_override("background", _bar_bg_style())
	bar.add_theme_stylebox_override("fill", _bar_fill_style())
	vbox.add_child(bar)

	return panel


func _make_badge_button(achievement: Dictionary) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(72, 84)
	button.flat = true
	var unlocked: bool = achievement.get("unlocked", false)
	button.modulate = Color.WHITE if unlocked else UiTokens.PROFILE_BADGE_LOCKED
	button.text = "%s\n%s" % [
		str(achievement.get("icon", "?")),
		tr(str(achievement.get("title_key", ""))),
	]
	button.add_theme_font_size_override("font_size", 11)
	button.pressed.connect(_on_badge_pressed.bind(achievement))
	return button


func _make_history_card(row: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _card_style())

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)

	var result_icon := Label.new()
	result_icon.text = "✓" if row.get("won", false) else "✗"
	result_icon.add_theme_font_size_override("font_size", 22)
	result_icon.add_theme_color_override(
		"font_color",
		UiTokens.FEEDBACK_CORRECT if row.get("won", false) else UiTokens.FEEDBACK_WRONG
	)
	hbox.add_child(result_icon)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info)

	var title := Label.new()
	title.text = str(row.get("category_name", ""))
	title.add_theme_font_size_override("font_size", 16)
	info.add_child(title)

	var subtitle := Label.new()
	subtitle.text = tr("UI_PROFILE_HISTORY_LINE").format({
		"score": row.get("score", 0),
		"correct": row.get("correct_count", 0),
		"total": row.get("total_count", 0),
		"time": _format_age(int(row.get("age_hours", 0))),
	})
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", UiTokens.TAB_INACTIVE_COLOR)
	info.add_child(subtitle)

	return panel


func _make_empty_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", UiTokens.TAB_INACTIVE_COLOR)
	return label


func _card_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.PROFILE_CARD_BG
	style.border_color = UiTokens.PROFILE_CARD_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(UiTokens.PROFILE_CARD_RADIUS)
	return style


func _bar_bg_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.PROFILE_MASTERY_BAR_BG
	style.set_corner_radius_all(5)
	return style


func _bar_fill_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.PROFILE_MASTERY_BAR_FILL
	style.set_corner_radius_all(5)
	return style


func _clear_container(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func _format_age(hours: int) -> String:
	if hours <= 0:
		return tr("UI_PROFILE_TIME_NOW")
	if hours < 24:
		return tr("UI_PROFILE_TIME_HOURS").format({"hours": hours})
	return tr("UI_PROFILE_TIME_DAYS").format({"days": int(hours / 24.0)})


func _play_entrance_animation() -> void:
	var delay := 0.0
	for node in _animated_nodes:
		if not is_instance_valid(node):
			continue
		node.modulate.a = 0.0
		node.position.y += 12.0
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(node, "modulate:a", 1.0, 0.28).set_delay(delay)
		tween.tween_property(node, "position:y", node.position.y - 12.0, 0.28).set_delay(delay)
		delay += 0.04
	_animated_nodes.clear()


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
	SaveManager.set_player_name(pseudo_input.text)
	profile_status_label.text = tr("UI_PROFILE_SAVED")
	refresh()


func _on_change_photo_pressed() -> void:
	photo_dialog.popup_centered_ratio(0.8)


func _on_remove_photo_pressed() -> void:
	SaveManager.clear_profile_avatar()
	profile_status_label.text = ""
	refresh()


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
