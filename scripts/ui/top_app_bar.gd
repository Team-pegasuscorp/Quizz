class_name TopAppBar
extends Control

signal settings_pressed

const UiTokens = preload("res://scripts/config/ui_tokens.gd")
const UiStyle = preload("res://scripts/config/ui_style.gd")
const PressScaleUtil = preload("res://scripts/ui/press_scale.gd")

@onready var bar: PanelContainer = %Bar
@onready var shell_margin: MarginContainer = %ShellMargin
@onready var logo_texture: TextureRect = %LogoTexture
@onready var title_label: Label = %TitleLabel
@onready var settings_button: Button = %SettingsButton


func _ready() -> void:
	clip_contents = false
	custom_minimum_size.y = UiTokens.HEADER_SHELL_HEIGHT
	shell_margin.add_theme_constant_override("margin_left", UiTokens.HEADER_SHELL_MARGIN_H)
	shell_margin.add_theme_constant_override("margin_right", UiTokens.HEADER_SHELL_MARGIN_H)
	shell_margin.add_theme_constant_override("margin_top", UiTokens.HEADER_SHELL_MARGIN_TOP)
	shell_margin.add_theme_constant_override("margin_bottom", UiTokens.HEADER_SHELL_MARGIN_BOTTOM)
	bar.custom_minimum_size.y = UiTokens.HEADER_BANNER_HEIGHT
	bar.add_theme_stylebox_override("panel", UiStyle.header_bar())
	_configure_logo()
	_configure_title()
	_configure_settings_button()
	_apply_translations()
	LocaleManager.locale_changed.connect(_on_locale_changed)
	PressScaleUtil.wire(settings_button, self)


func _configure_logo() -> void:
	var logo_size := Vector2.ONE * UiTokens.HEADER_LOGO_SIZE
	logo_texture.custom_minimum_size = logo_size
	logo_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo_texture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	logo_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(UiTokens.APP_LOGO_PATH):
		logo_texture.texture = load(UiTokens.APP_LOGO_PATH)
		logo_texture.visible = true
	else:
		logo_texture.visible = false


func _configure_title() -> void:
	title_label.add_theme_color_override("font_color", UiTokens.HEADER_BANNER_FG)
	title_label.add_theme_font_size_override("font_size", UiTokens.HEADER_TITLE_SIZE)
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _configure_settings_button() -> void:
	var tile_size := Vector2.ONE * UiTokens.HEADER_SETTINGS_SIZE
	settings_button.custom_minimum_size = tile_size
	settings_button.size = tile_size
	settings_button.text = ""
	settings_button.flat = false
	settings_button.expand_icon = false
	settings_button.icon = load("res://assets/ui/icon_settings.svg")
	settings_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	settings_button.focus_mode = Control.FOCUS_ALL
	settings_button.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_button.add_theme_constant_override("icon_max_width", UiTokens.HEADER_SETTINGS_ICON_SIZE)
	settings_button.add_theme_constant_override("h_separation", 0)
	settings_button.add_theme_color_override("icon_normal_color", UiTokens.INK)
	settings_button.add_theme_color_override("icon_hover_color", UiTokens.ACCENT_QUIZ_DEEP)
	settings_button.add_theme_color_override("icon_pressed_color", UiTokens.ACCENT_QUIZ_DEEP)
	settings_button.add_theme_stylebox_override("normal", UiStyle.settings_chip())
	settings_button.add_theme_stylebox_override("hover", UiStyle.settings_chip())
	settings_button.add_theme_stylebox_override("pressed", UiStyle.settings_chip())
	settings_button.add_theme_stylebox_override("focus", UiStyle.settings_chip())
	if not settings_button.pressed.is_connected(_on_settings_pressed):
		settings_button.pressed.connect(_on_settings_pressed)


func _apply_translations() -> void:
	title_label.text = tr("UI_APP_TITLE")
	settings_button.tooltip_text = tr("UI_SETTINGS")


func release_settings_focus() -> void:
	settings_button.release_focus()


func _on_settings_pressed() -> void:
	settings_pressed.emit()


func _on_locale_changed(_locale: String) -> void:
	_apply_translations()
