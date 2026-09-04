## Home tab page. Edit this script and `scenes/tabs/home_tab.tscn` only.
extends Control

const UiTokens = preload("res://scripts/config/ui_tokens.gd")
const UiStyle = preload("res://scripts/config/ui_style.gd")
const ProfileSnapshot = preload("res://scripts/profile/profile_snapshot.gd")

@onready var subtitle_label: Label = %SubtitleLabel
@onready var content: VBoxContainer = %Content

var _cards: Array[Control] = []


func _ready() -> void:
	_rebuild()
	LocaleManager.locale_changed.connect(_on_locale_changed)


func on_tab_shown() -> void:
	_rebuild()


func _rebuild() -> void:
	_apply_translations()
	_rebuild_cards()


func _apply_translations() -> void:
	var snapshot: Dictionary = ProfileSnapshot.build_full(LocaleManager.get_content_locale())
	var name: String = str(snapshot.get("player_name", UiTokens.DEFAULT_PLAYER_NAME))
	subtitle_label.text = tr("UI_HOME_HELLO").format({"name": name})


func _rebuild_cards() -> void:
	for child in content.get_children():
		child.queue_free()
	_cards.clear()

	var snapshot: Dictionary = ProfileSnapshot.build_full(LocaleManager.get_content_locale())
	content.add_child(_make_progress_card(snapshot))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.add_child(_make_stat_chip(
		tr("UI_PROFILE_WIN_STREAK"),
		str(snapshot.get("current_win_streak", 0)),
		UiTokens.ACCENT_HOME
	))
	row.add_child(_make_stat_chip(
		tr("UI_TAB_LEADERBOARD"),
		tr(str(snapshot.get("rank_title_key", "UI_RANK_ROOKIE"))),
		UiTokens.ACCENT_LEADERBOARD
	))
	content.add_child(row)
	content.add_child(_make_hint_card())


func _make_progress_card(snapshot: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", UiStyle.card(UiTokens.ACCENT_XP))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var level := Label.new()
	level.text = tr("UI_PLAYER_LEVEL").format({"level": snapshot.get("level", 1)})
	level.add_theme_font_size_override("font_size", 22)
	level.add_theme_color_override("font_color", UiTokens.INK)
	vbox.add_child(level)

	var bar := ProgressBar.new()
	bar.custom_minimum_size.y = 12
	bar.max_value = snapshot.get("xp_to_next", 100)
	bar.value = snapshot.get("xp", 0)
	bar.show_percentage = false
	bar.add_theme_stylebox_override("background", UiStyle.progress_bg())
	bar.add_theme_stylebox_override("fill", UiStyle.progress_fill(UiTokens.ACCENT_XP))
	vbox.add_child(bar)

	var xp := Label.new()
	xp.text = tr("UI_PROFILE_XP_PROGRESS").format({
		"current": snapshot.get("xp", 0),
		"target": snapshot.get("xp_to_next", 100),
	})
	xp.add_theme_font_size_override("font_size", 13)
	xp.add_theme_color_override("font_color", UiTokens.INK_MUTED)
	vbox.add_child(xp)
	return panel


func _make_stat_chip(caption: String, value: String, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size.y = 96
	panel.add_theme_stylebox_override("panel", UiStyle.card(accent))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
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
	caption_label.add_theme_font_size_override("font_size", 12)
	caption_label.add_theme_color_override("font_color", UiTokens.INK_MUTED)
	vbox.add_child(caption_label)
	return panel


func _make_hint_card() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiStyle.card(UiTokens.ACCENT_QUIZ))
	var label := Label.new()
	label.text = tr("UI_HOME_QUIZ_HINT")
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", UiTokens.INK)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)
	margin.add_child(label)
	return panel


func _on_locale_changed(_locale: String) -> void:
	_rebuild()
