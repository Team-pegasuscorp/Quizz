extends Control

const UiTokens = preload("res://scripts/config/ui_tokens.gd")
const ScenePaths = preload("res://scripts/config/scene_paths.gd")
const PressScaleUtil = preload("res://scripts/ui/press_scale.gd")

@onready var title_label: Label = %TitleLabel
@onready var settings_button: Button = %SettingsButton
@onready var tab_swipe = %TabSwipeContainer
@onready var bottom_nav: PanelContainer = %BottomNavBar
@onready var home_tab: Control = %HomeTab
@onready var profile_tab: Control = %ProfileTab
@onready var settings_backdrop: ColorRect = %SettingsBackdrop
@onready var language_option: OptionButton = %LanguageOption
@onready var language_label: Label = %LanguageLabel
@onready var settings_panel: PanelContainer = %SettingsPanel
@onready var close_settings_button: Button = %CloseSettingsButton


func _ready() -> void:
	tab_swipe.swipe_threshold = UiTokens.TAB_SWIPE_THRESHOLD
	tab_swipe.drag_lock_threshold = UiTokens.TAB_SWIPE_DRAG_LOCK
	tab_swipe.animation_duration = UiTokens.TAB_SWIPE_DURATION
	_configure_top_banner()
	_configure_settings_button()
	_apply_translations()
	_setup_language_option()
	_wire_navigation()
	_connect_settings()
	LocaleManager.locale_changed.connect(_on_locale_changed)
	PressScaleUtil.wire(close_settings_button, self)

	var initial_tab: int = clampi(GameManager.shell_tab_index, 0, ScenePaths.TAB_COUNT - 1)
	var initial_page: int = ScenePaths.page_index_for_tab(initial_tab)
	tab_swipe.set_tab(initial_page, false)
	bottom_nav.set_active_tab(initial_page)
	if initial_tab == ScenePaths.Tab.PROFILE:
		_refresh_profile_tab()


func _wire_navigation() -> void:
	bottom_nav.tab_selected.connect(_on_bottom_nav_selected)
	tab_swipe.tab_changed.connect(_on_tab_changed)
	home_tab.play_requested.connect(_on_home_play_requested)


func _connect_settings() -> void:
	settings_button.pressed.connect(_on_settings_pressed)
	settings_backdrop.gui_input.connect(_on_settings_backdrop_gui_input)
	close_settings_button.pressed.connect(_on_close_settings_pressed)
	language_option.item_selected.connect(_on_language_selected)


func _unhandled_input(event: InputEvent) -> void:
	if not settings_panel.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_close_settings()
		get_viewport().set_input_as_handled()


func _configure_top_banner() -> void:
	title_label.add_theme_color_override("font_color", UiTokens.HEADER_BANNER_FG)


func _configure_settings_button() -> void:
	var tile_size := Vector2.ONE * UiTokens.HEADER_SETTINGS_SIZE
	settings_button.custom_minimum_size = tile_size
	settings_button.text = ""
	settings_button.flat = true
	settings_button.focus_mode = Control.FOCUS_ALL
	settings_button.mouse_filter = Control.MOUSE_FILTER_STOP
	settings_button.add_theme_constant_override("icon_max_width", UiTokens.HEADER_SETTINGS_ICON_SIZE)
	settings_button.add_theme_constant_override("icon_max_height", UiTokens.HEADER_SETTINGS_ICON_SIZE)
	settings_button.add_theme_color_override("icon_normal_color", UiTokens.HEADER_BANNER_FG)
	settings_button.add_theme_color_override("icon_hover_color", Color.WHITE)
	settings_button.add_theme_color_override("icon_pressed_color", UiTokens.BRAND_CYAN)


func _apply_translations() -> void:
	title_label.text = tr("UI_APP_TITLE")
	settings_button.tooltip_text = tr("UI_SETTINGS")
	language_label.text = tr("UI_LANGUAGE")
	close_settings_button.text = tr("UI_BACK")


func _setup_language_option() -> void:
	language_option.clear()
	var locales: Array[String] = LocaleManager.get_supported_locales()
	for index in range(locales.size()):
		var locale: String = locales[index]
		language_option.add_item(LocaleManager.get_locale_display_name(locale), index)
		language_option.set_item_metadata(index, locale)
		if locale == LocaleManager.current_locale:
			language_option.select(index)


func _on_bottom_nav_selected(index: int) -> void:
	tab_swipe.set_tab(index, true)


func _on_tab_changed(page_index: int) -> void:
	bottom_nav.set_active_tab(page_index)
	var tab_id: int = ScenePaths.tab_for_page_index(page_index)
	GameManager.shell_tab_index = tab_id
	if tab_id == ScenePaths.Tab.PROFILE:
		_refresh_profile_tab()


func _on_home_play_requested() -> void:
	tab_swipe.set_tab(ScenePaths.page_index_for_tab(ScenePaths.Tab.QUIZ), true)


func _refresh_profile_tab() -> void:
	if profile_tab.has_method("refresh"):
		profile_tab.call("refresh")


func _on_settings_pressed() -> void:
	_open_settings()


func _open_settings() -> void:
	tab_swipe.set_input_enabled(false)
	settings_backdrop.visible = true
	settings_panel.visible = true
	settings_panel.move_to_front()
	settings_button.release_focus()
	language_option.grab_focus()


func _close_settings() -> void:
	tab_swipe.set_input_enabled(true)
	settings_backdrop.visible = false
	settings_panel.visible = false


func _on_settings_backdrop_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_close_settings()


func _on_close_settings_pressed() -> void:
	_close_settings()


func _on_language_selected(index: int) -> void:
	var locale: String = str(language_option.get_item_metadata(index))
	LocaleManager.set_locale(locale)


func _on_locale_changed(_locale: String) -> void:
	_apply_translations()
	_setup_language_option()
	_refresh_profile_tab()
