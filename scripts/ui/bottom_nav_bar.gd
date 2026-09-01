extends PanelContainer

signal tab_selected(page_index: int)

const UiTokens = preload("res://scripts/config/ui_tokens.gd")
const ScenePaths = preload("res://scripts/config/scene_paths.gd")

@onready var tabs_row: HBoxContainer = %TabsRow

var _tab_items: Array[Control] = []
var _tab_icons: Array[TextureRect] = []
var _tab_labels: Array[Label] = []
var _tab_indicators: Array[ColorRect] = []
var _page_tab_ids: Array[int] = []
var _current_page: int = 0

var _quiz_slot: Control
var _quiz_glow: PanelContainer
var _quiz_disc: PanelContainer
var _quiz_button: Button
var _quiz_icon: TextureRect
var _quiz_label: Label
var _quiz_glow_tween: Tween
var _quiz_press_tween: Tween

const _LABEL_KEYS := {
	ScenePaths.Tab.HOME: "UI_TAB_HOME",
	ScenePaths.Tab.QUIZ: "UI_TAB_QUIZ",
	ScenePaths.Tab.MULTIPLAYER: "UI_TAB_MULTIPLAYER",
	ScenePaths.Tab.LEADERBOARD: "UI_TAB_LEADERBOARD",
	ScenePaths.Tab.PROFILE: "UI_TAB_PROFILE",
}


func _ready() -> void:
	clip_contents = false
	custom_minimum_size.y = UiTokens.BOTTOM_NAV_HEIGHT
	_build_tabs()
	LocaleManager.locale_changed.connect(_on_locale_changed)


func set_active_tab(page_index: int) -> void:
	_current_page = clampi(page_index, 0, _tab_items.size() - 1)
	for slot in range(_tab_items.size()):
		var is_active := slot == _current_page
		var tab_id: int = _page_tab_ids[slot]
		if tab_id == ScenePaths.Tab.QUIZ:
			continue
		_tab_indicators[slot].visible = is_active
		var active_color := UiTokens.TAB_ACTIVE_COLOR
		var inactive_color := UiTokens.TAB_INACTIVE_COLOR
		_tab_icons[slot].modulate = active_color if is_active else inactive_color
		_tab_labels[slot].add_theme_color_override(
			"font_color",
			active_color if is_active else inactive_color
		)
		_tab_labels[slot].add_theme_font_size_override(
			"font_size",
			UiTokens.SECONDARY_NAV_LABEL_SIZE_ACTIVE if is_active else UiTokens.SECONDARY_NAV_LABEL_SIZE_INACTIVE
		)
		_tab_items[slot].modulate.a = 1.0 if is_active else UiTokens.SECONDARY_NAV_INACTIVE_ALPHA

	_update_quiz_fab_state(_page_tab_ids[_current_page] == ScenePaths.Tab.QUIZ)


func _build_tabs() -> void:
	for child in tabs_row.get_children():
		child.queue_free()
	_tab_items.clear()
	_tab_icons.clear()
	_tab_labels.clear()
	_tab_indicators.clear()
	_page_tab_ids.clear()
	_quiz_slot = null
	_quiz_glow = null
	_quiz_disc = null
	_quiz_button = null
	_quiz_icon = null
	_quiz_label = null

	for page_index in range(ScenePaths.TAB_COUNT):
		var tab_id: int = ScenePaths.TAB_PAGE_ORDER[page_index]
		var item: Control
		if tab_id == ScenePaths.Tab.QUIZ:
			item = _make_quiz_fab(page_index)
		else:
			item = _make_secondary_tab(page_index, tab_id)
		tabs_row.add_child(item)
		_tab_items.append(item)
		_page_tab_ids.append(tab_id)

	_apply_translations()
	set_active_tab(_current_page)


func _make_secondary_tab(page_index: int, tab_id: int) -> Control:
	var wrapper := Control.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.custom_minimum_size.y = UiTokens.BOTTOM_NAV_HEIGHT - 8.0
	wrapper.mouse_filter = Control.MOUSE_FILTER_PASS

	var button := Button.new()
	button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.flat = true
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.pressed.connect(_on_tab_pressed.bind(page_index))
	wrapper.add_child(button)

	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 3)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(column)

	var indicator := ColorRect.new()
	indicator.custom_minimum_size = Vector2(18, UiTokens.BOTTOM_NAV_INDICATOR_HEIGHT)
	indicator.color = UiTokens.BRAND_CYAN
	indicator.visible = false
	indicator.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(indicator)
	_tab_indicators.append(indicator)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(
		UiTokens.SECONDARY_NAV_ICON_SIZE,
		UiTokens.SECONDARY_NAV_ICON_SIZE
	)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = load(UiTokens.TAB_ICON_PATHS[tab_id])
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(icon)
	_tab_icons.append(icon)

	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(label)
	_tab_labels.append(label)

	return wrapper


func _make_quiz_fab(page_index: int) -> Control:
	var wrapper := Control.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.custom_minimum_size.y = UiTokens.BOTTOM_NAV_HEIGHT
	wrapper.clip_contents = false
	wrapper.mouse_filter = Control.MOUSE_FILTER_PASS
	wrapper.resized.connect(_center_quiz_fab)
	_quiz_slot = wrapper

	var fab_layer := Control.new()
	fab_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fab_layer.custom_minimum_size = Vector2(UiTokens.QUIZ_FAB_GLOW_SIZE, UiTokens.QUIZ_FAB_GLOW_SIZE)
	wrapper.add_child(fab_layer)

	_quiz_glow = PanelContainer.new()
	_quiz_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_quiz_glow.custom_minimum_size = Vector2(UiTokens.QUIZ_FAB_GLOW_SIZE, UiTokens.QUIZ_FAB_GLOW_SIZE)
	_quiz_glow.add_theme_stylebox_override("panel", _glow_style())
	_quiz_glow.visible = false
	_quiz_glow.modulate = Color(1, 1, 1, 0.35)
	fab_layer.add_child(_quiz_glow)

	_quiz_disc = PanelContainer.new()
	_quiz_disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_quiz_disc.custom_minimum_size = Vector2(UiTokens.QUIZ_FAB_SIZE, UiTokens.QUIZ_FAB_SIZE)
	_quiz_disc.add_theme_stylebox_override("panel", _fab_disc_style(UiTokens.BRAND_ORANGE))
	fab_layer.add_child(_quiz_disc)

	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 1)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_quiz_disc.add_child(column)

	_quiz_icon = TextureRect.new()
	_quiz_icon.custom_minimum_size = Vector2(UiTokens.QUIZ_FAB_ICON_SIZE, UiTokens.QUIZ_FAB_ICON_SIZE)
	_quiz_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_quiz_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_quiz_icon.texture = load(UiTokens.TAB_ICON_PATHS[ScenePaths.Tab.QUIZ])
	_quiz_icon.modulate = Color.WHITE
	_quiz_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(_quiz_icon)

	_quiz_label = Label.new()
	_quiz_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_quiz_label.add_theme_font_size_override("font_size", UiTokens.QUIZ_FAB_LABEL_SIZE)
	_quiz_label.add_theme_color_override("font_color", Color.WHITE)
	_quiz_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(_quiz_label)

	_quiz_button = Button.new()
	_quiz_button.flat = true
	_quiz_button.focus_mode = Control.FOCUS_ALL
	_quiz_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_quiz_button.custom_minimum_size = Vector2(UiTokens.QUIZ_FAB_SIZE, UiTokens.QUIZ_FAB_SIZE)
	_quiz_button.pressed.connect(_on_tab_pressed.bind(page_index))
	_quiz_button.button_down.connect(_on_quiz_button_down)
	_quiz_button.button_up.connect(_on_quiz_button_up)
	fab_layer.add_child(_quiz_button)

	_tab_icons.append(_quiz_icon)
	_tab_labels.append(_quiz_label)
	_tab_indicators.append(ColorRect.new())

	fab_layer.set_meta("fab_layer", true)
	call_deferred("_center_quiz_fab")
	return wrapper


func _center_quiz_fab() -> void:
	if _quiz_slot == null:
		return
	var fab_layer: Control = null
	for child in _quiz_slot.get_children():
		if child.get_meta("fab_layer", false):
			fab_layer = child as Control
			break
	if fab_layer == null:
		return

	var layer_size := Vector2(UiTokens.QUIZ_FAB_GLOW_SIZE, UiTokens.QUIZ_FAB_GLOW_SIZE)
	fab_layer.size = layer_size
	fab_layer.position = Vector2(
		(_quiz_slot.size.x - layer_size.x) * 0.5,
		-UiTokens.QUIZ_FAB_LIFT
	)

	var glow_offset := (layer_size.x - UiTokens.QUIZ_FAB_GLOW_SIZE) * 0.5
	_quiz_glow.position = Vector2(glow_offset, glow_offset)

	var disc_offset := (layer_size.x - UiTokens.QUIZ_FAB_SIZE) * 0.5
	_quiz_disc.position = Vector2(disc_offset, disc_offset)
	_quiz_disc.size = Vector2(UiTokens.QUIZ_FAB_SIZE, UiTokens.QUIZ_FAB_SIZE)

	_quiz_button.position = _quiz_disc.position
	_quiz_button.size = _quiz_disc.size
	_quiz_button.pivot_offset = _quiz_button.size * 0.5


func _fab_disc_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(UiTokens.QUIZ_FAB_CORNER_RADIUS)
	style.shadow_color = Color(0, 0, 0, 0.38)
	style.shadow_size = UiTokens.QUIZ_FAB_SHADOW_SIZE
	style.border_width_bottom = 2
	style.border_color = Color(1, 1, 1, 0.18)
	return style


func _glow_style() -> StyleBoxFlat:
	var glow_radius := int(
		float(UiTokens.QUIZ_FAB_CORNER_RADIUS) * UiTokens.QUIZ_FAB_GLOW_SIZE / UiTokens.QUIZ_FAB_SIZE
	)
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.QUIZ_FAB_GLOW_COLOR
	style.set_corner_radius_all(glow_radius)
	return style


func _update_quiz_fab_state(is_active: bool) -> void:
	if _quiz_disc == null:
		return

	_stop_quiz_glow_tween()
	if is_active:
		_quiz_disc.modulate = Color.WHITE
		_quiz_disc.add_theme_stylebox_override("panel", _fab_disc_style(UiTokens.BRAND_ORANGE))
		_quiz_glow.visible = true
		_quiz_glow.modulate.a = 0.35
		_quiz_glow_tween = create_tween().set_loops()
		_quiz_glow_tween.tween_property(_quiz_glow, "modulate:a", 0.58, UiTokens.QUIZ_FAB_GLOW_DURATION * 0.5)
		_quiz_glow_tween.tween_property(_quiz_glow, "modulate:a", 0.28, UiTokens.QUIZ_FAB_GLOW_DURATION * 0.5)
	else:
		_quiz_glow.visible = false
		_quiz_disc.modulate = Color(1, 1, 1, UiTokens.QUIZ_FAB_INACTIVE_ALPHA)
		_quiz_disc.add_theme_stylebox_override(
			"panel",
			_fab_disc_style(Color(UiTokens.BRAND_ORANGE.r, UiTokens.BRAND_ORANGE.g, UiTokens.BRAND_ORANGE.b, 0.88))
		)


func _stop_quiz_glow_tween() -> void:
	if _quiz_glow_tween != null and _quiz_glow_tween.is_valid():
		_quiz_glow_tween.kill()
	_quiz_glow_tween = null


func _on_quiz_button_down() -> void:
	if _quiz_disc == null:
		return
	if _quiz_press_tween != null and _quiz_press_tween.is_valid():
		_quiz_press_tween.kill()
	_quiz_disc.pivot_offset = _quiz_disc.size * 0.5
	_quiz_press_tween = create_tween()
	_quiz_press_tween.tween_property(
		_quiz_disc,
		"scale",
		Vector2.ONE * UiTokens.QUIZ_FAB_PRESS_SCALE,
		UiTokens.QUIZ_FAB_PRESS_DURATION
	)


func _on_quiz_button_up() -> void:
	if _quiz_disc == null:
		return
	if _quiz_press_tween != null and _quiz_press_tween.is_valid():
		_quiz_press_tween.kill()
	_quiz_press_tween = create_tween()
	_quiz_press_tween.tween_property(_quiz_disc, "scale", Vector2.ONE, UiTokens.QUIZ_FAB_PRESS_DURATION)


func _apply_translations() -> void:
	for slot in range(_page_tab_ids.size()):
		var tab_id: int = _page_tab_ids[slot]
		if slot < _tab_labels.size():
			_tab_labels[slot].text = tr(_LABEL_KEYS.get(tab_id, ""))


func _on_tab_pressed(page_index: int) -> void:
	tab_selected.emit(page_index)


func _on_locale_changed(_locale: String) -> void:
	_apply_translations()
