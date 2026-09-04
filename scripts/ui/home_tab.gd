## Home tab — BrainUp splash matching brand sheet.
extends Control

signal play_requested
signal login_requested

const UiTokens = preload("res://scripts/config/ui_tokens.gd")
const UiStyle = preload("res://scripts/config/ui_style.gd")
const PressScaleUtil = preload("res://scripts/ui/press_scale.gd")

@onready var logo_texture: TextureRect = %LogoTexture
@onready var play_button: Button = %PlayButton
@onready var login_button: Button = %LoginButton


func _ready() -> void:
	_configure_logo()
	_configure_buttons()
	_apply_translations()
	LocaleManager.locale_changed.connect(_on_locale_changed)


func on_tab_shown() -> void:
	_apply_translations()


func _configure_logo() -> void:
	logo_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo_texture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if ResourceLoader.exists(UiTokens.BRAND_LOGO_FULL_PATH):
		logo_texture.texture = load(UiTokens.BRAND_LOGO_FULL_PATH)


func _configure_buttons() -> void:
	play_button.theme_type_variation = &"PrimaryButton"
	play_button.custom_minimum_size.y = 58
	login_button.flat = false
	login_button.custom_minimum_size.y = 54
	login_button.add_theme_stylebox_override("normal", _ghost_style(false))
	login_button.add_theme_stylebox_override("hover", _ghost_style(true))
	login_button.add_theme_stylebox_override("pressed", _ghost_style(true))
	login_button.add_theme_stylebox_override("focus", _ghost_style(true))
	login_button.add_theme_color_override("font_color", UiTokens.BRAND_WHITE)
	login_button.add_theme_color_override("font_hover_color", UiTokens.BRAND_WHITE)
	login_button.add_theme_color_override("font_pressed_color", UiTokens.BRAND_WHITE)
	play_button.pressed.connect(_on_play_pressed)
	login_button.pressed.connect(_on_login_pressed)
	PressScaleUtil.wire(play_button, self)
	PressScaleUtil.wire(login_button, self)


func _ghost_style(emphasized: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.04 if emphasized else 0.0)
	style.set_border_width_all(2)
	style.border_color = Color(1, 1, 1, 0.95 if emphasized else 0.85)
	style.set_corner_radius_all(22)
	style.content_margin_left = 22
	style.content_margin_top = 14
	style.content_margin_right = 22
	style.content_margin_bottom = 14
	return style


func _apply_translations() -> void:
	play_button.text = tr("UI_PLAY")
	login_button.text = tr("UI_LOGIN")


func _on_play_pressed() -> void:
	play_requested.emit()


func _on_login_pressed() -> void:
	login_requested.emit()


func _on_locale_changed(_locale: String) -> void:
	_apply_translations()
