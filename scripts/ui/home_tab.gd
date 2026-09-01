extends Control

signal play_requested

const PressScaleUtil = preload("res://scripts/ui/press_scale.gd")

@onready var subtitle_label: Label = %SubtitleLabel
@onready var play_button: Button = %PlayButton


func _ready() -> void:
	_apply_translations()
	play_button.pressed.connect(_on_play_pressed)
	LocaleManager.locale_changed.connect(_on_locale_changed)
	PressScaleUtil.wire(play_button, self)


func _apply_translations() -> void:
	subtitle_label.text = tr("UI_APP_SUBTITLE")
	play_button.text = tr("UI_PLAY")


func _on_play_pressed() -> void:
	play_requested.emit()


func _on_locale_changed(_locale: String) -> void:
	_apply_translations()
