extends Control

const PressScaleUtil = preload("res://scripts/ui/press_scale.gd")

@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var level_label: Label = %LevelLabel
@onready var menu_player_name_label: Label = %MenuPlayerNameLabel
@onready var menu_avatar_texture: TextureRect = %MenuAvatarTexture
@onready var play_button: Button = %PlayButton
@onready var profile_button: Button = %ProfileButton
@onready var settings_button: Button = %SettingsButton
@onready var language_option: OptionButton = %LanguageOption
@onready var language_label: Label = %LanguageLabel
@onready var settings_panel: PanelContainer = %SettingsPanel
@onready var close_settings_button: Button = %CloseSettingsButton


func _ready() -> void:
	_apply_translations()
	_refresh_profile_card()
	_setup_language_option()
	play_button.pressed.connect(_on_play_pressed)
	profile_button.pressed.connect(_on_profile_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	close_settings_button.pressed.connect(_on_close_settings_pressed)
	language_option.item_selected.connect(_on_language_selected)
	LocaleManager.locale_changed.connect(_on_locale_changed)
	PressScaleUtil.wire(play_button, self)
	PressScaleUtil.wire(profile_button, self)
	PressScaleUtil.wire(settings_button, self)
	PressScaleUtil.wire(close_settings_button, self)


func _apply_translations() -> void:
	title_label.text = tr("UI_APP_TITLE")
	subtitle_label.text = tr("UI_APP_SUBTITLE")
	play_button.text = tr("UI_PLAY")
	profile_button.text = tr("UI_PROFILE")
	settings_button.text = tr("UI_SETTINGS")
	language_label.text = tr("UI_LANGUAGE")
	close_settings_button.text = tr("UI_BACK")
	level_label.text = tr("UI_PLAYER_LEVEL").format({"level": SaveManager.level})


func _refresh_profile_card() -> void:
	menu_player_name_label.text = SaveManager.player_name
	menu_avatar_texture.texture = SaveManager.get_profile_avatar_texture()
	level_label.text = tr("UI_PLAYER_LEVEL").format({"level": SaveManager.level})


func _setup_language_option() -> void:
	language_option.clear()
	var locales: Array[String] = LocaleManager.get_supported_locales()
	for index in range(locales.size()):
		var locale: String = locales[index]
		language_option.add_item(LocaleManager.get_locale_display_name(locale), index)
		language_option.set_item_metadata(index, locale)
		if locale == LocaleManager.current_locale:
			language_option.select(index)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/category_select.tscn")


func _on_profile_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/profile/player_profile.tscn")


func _on_settings_pressed() -> void:
	settings_panel.visible = true


func _on_close_settings_pressed() -> void:
	settings_panel.visible = false


func _on_language_selected(index: int) -> void:
	var locale: String = str(language_option.get_item_metadata(index))
	LocaleManager.set_locale(locale)


func _on_locale_changed(_locale: String) -> void:
	_apply_translations()
	_refresh_profile_card()
	_setup_language_option()
