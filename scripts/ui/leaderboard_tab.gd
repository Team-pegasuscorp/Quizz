## Leaderboard tab page. Edit this script and `scenes/tabs/leaderboard_tab.tscn` only.
extends Control

const UiTokens = preload("res://scripts/config/ui_tokens.gd")
const UiStyle = preload("res://scripts/config/ui_style.gd")

@onready var title_label: Label = %TitleLabel
@onready var content: VBoxContainer = %Content
@onready var message_label: Label = %MessageLabel


func _ready() -> void:
	_apply()
	LocaleManager.locale_changed.connect(_on_locale_changed)


func on_tab_shown() -> void:
	_apply()


func _apply() -> void:
	title_label.text = tr("UI_TAB_LEADERBOARD")
	message_label.text = tr("UI_COMING_SOON_DESC")
	_rebuild_podium()


func _rebuild_podium() -> void:
	for child in content.get_children():
		if child != message_label:
			child.queue_free()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(row)
	content.move_child(row, 0)
	var ranks := [
		{"place": "2", "h": 92, "color": Color(0.72, 0.78, 0.86, 1)},
		{"place": "1", "h": 120, "color": UiTokens.ACCENT_LEADERBOARD},
		{"place": "3", "h": 80, "color": Color(0.85, 0.62, 0.42, 1)},
	]
	for rank in ranks:
		row.add_child(_podium_card(str(rank.place), float(rank.h), rank.color))


func _podium_card(place: String, height: float, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(88, height)
	panel.size_flags_vertical = Control.SIZE_SHRINK_END
	panel.add_theme_stylebox_override("panel", UiStyle.card(accent))
	var label := Label.new()
	label.text = place
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", accent)
	panel.add_child(label)
	return panel


func _on_locale_changed(_locale: String) -> void:
	_apply()
