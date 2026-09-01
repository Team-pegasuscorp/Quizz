extends Control

@export var message_key: String = "UI_COMING_SOON"

@onready var title_label: Label = %TitleLabel
@onready var message_label: Label = %MessageLabel


func _ready() -> void:
	_apply_translations()
	LocaleManager.locale_changed.connect(_on_locale_changed)


func _apply_translations() -> void:
	title_label.text = tr(message_key)
	message_label.text = tr("UI_COMING_SOON_DESC")


func _on_locale_changed(_locale: String) -> void:
	_apply_translations()
