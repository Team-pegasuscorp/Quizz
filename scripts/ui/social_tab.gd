## Social tab page. Edit this script and `scenes/tabs/social_tab.tscn` only.
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
	title_label.text = tr("UI_TAB_SOCIAL")
	message_label.text = tr("UI_COMING_SOON_DESC")
	_rebuild_cards()


func _rebuild_cards() -> void:
	for child in content.get_children():
		if child != message_label:
			child.queue_free()
	content.add_child(_friend_card("Alex", tr("UI_SOCIAL_CHALLENGE_HINT")))
	content.add_child(_friend_card("Maya", tr("UI_SOCIAL_CHALLENGE_HINT")))
	content.move_child(message_label, content.get_child_count() - 1)


func _friend_card(name: String, caption: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiStyle.card(UiTokens.ACCENT_SOCIAL))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	panel.add_child(row)

	var avatar := PanelContainer.new()
	avatar.custom_minimum_size = Vector2(48, 48)
	avatar.add_theme_stylebox_override("panel", UiStyle.filled_disc(UiTokens.ACCENT_SOCIAL, 24))
	var initial := Label.new()
	initial.text = name.substr(0, 1)
	initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	initial.add_theme_color_override("font_color", Color.WHITE)
	initial.add_theme_font_size_override("font_size", 20)
	avatar.add_child(initial)
	row.add_child(avatar)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var name_label := Label.new()
	name_label.text = name
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", UiTokens.INK)
	info.add_child(name_label)
	var cap := Label.new()
	cap.text = caption
	cap.add_theme_font_size_override("font_size", 13)
	cap.add_theme_color_override("font_color", UiTokens.INK_MUTED)
	info.add_child(cap)
	row.add_child(info)
	return panel


func _on_locale_changed(_locale: String) -> void:
	_apply()
