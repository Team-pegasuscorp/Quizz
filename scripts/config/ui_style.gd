class_name UiStyle
extends RefCounted

const UiTokens = preload("res://scripts/config/ui_tokens.gd")


static func card(accent: Color = Color(0, 0, 0, 0), radius: int = -1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.CARD_BG
	style.set_border_width_all(0)
	style.set_corner_radius_all(UiTokens.CARD_RADIUS if radius < 0 else radius)
	style.shadow_color = UiTokens.CARD_SHADOW
	style.shadow_size = 14
	style.shadow_offset = Vector2(0, 3)
	style.content_margin_left = 16
	style.content_margin_top = 16
	style.content_margin_right = 16
	style.content_margin_bottom = 16
	if accent.a > 0.02:
		style.shadow_color = Color(accent.r, accent.g, accent.b, 0.2)
		style.border_width_top = 3
		style.border_color = Color(accent.r, accent.g, accent.b, 0.9)
	return style


static func glass_panel(accent: Color = Color(1, 1, 1, 0.16), radius: int = -1) -> StyleBoxFlat:
	return card(accent, radius)


static func glass_strong(accent: Color = Color(1, 1, 1, 0.16), radius: int = -1) -> StyleBoxFlat:
	var style := card(accent, radius)
	style.bg_color = UiTokens.CARD_BG_SOFT
	return style


static func filled(color: Color, radius: int = 22) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(color.r, color.g, color.b, 0.32)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 4)
	return style


static func filled_disc(color: Color, radius: int) -> StyleBoxFlat:
	var style := filled(color, radius)
	style.shadow_size = UiTokens.QUIZ_FAB_SHADOW_SIZE
	style.shadow_color = Color(color.r, color.g, color.b, 0.18)
	style.border_width_bottom = 2
	style.border_color = Color(1, 1, 1, 0.35)
	style.anti_aliasing = true
	style.anti_aliasing_size = 1.0
	return style


static func glow_disc(color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, UiTokens.QUIZ_FAB_GLOW_COLOR.a)
	style.set_corner_radius_all(radius)
	return style


static func chip(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, 0.14)
	style.set_corner_radius_all(14)
	style.content_margin_left = 12
	style.content_margin_top = 6
	style.content_margin_right = 12
	style.content_margin_bottom = 6
	return style


static func progress_bg() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.PROFILE_MASTERY_BAR_BG
	style.set_corner_radius_all(10)
	return style


static func progress_fill(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(10)
	return style


static func nav_dock() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.BOTTOM_NAV_BG
	style.set_border_width_all(0)
	style.set_corner_radius_all(UiTokens.BOTTOM_NAV_CORNER_RADIUS)
	style.shadow_color = UiTokens.BOTTOM_NAV_GLOW
	style.shadow_size = 16
	style.shadow_offset = Vector2(0, 4)
	return style


static func nav_pill(accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(accent.r, accent.g, accent.b, 0.14)
	style.set_corner_radius_all(22)
	return style


static func header_bar() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.TOP_BAR_BG
	style.set_border_width_all(0)
	style.set_corner_radius_all(0)
	style.shadow_color = Color(0.08, 0.18, 0.32, 0.1)
	style.shadow_size = 6
	style.shadow_offset = Vector2(0, 2)
	return style


static func settings_chip() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var radius := int(round(UiTokens.HEADER_SETTINGS_SIZE * 0.5))
	style.bg_color = Color(1, 1, 1, 1)
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(0)
	style.shadow_color = UiTokens.CARD_SHADOW
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 0)
	return style


static func category_tile(accent: Color) -> StyleBoxFlat:
	var style := card(accent, 22)
	style.bg_color = Color(1, 1, 1, 1)
	return style


static func category_tile_selected(accent: Color) -> StyleBoxFlat:
	var style := category_tile(accent)
	style.bg_color = Color(accent.r, accent.g, accent.b, 0.12)
	style.set_border_width_all(2)
	style.border_color = Color(accent.r, accent.g, accent.b, 0.55)
	style.shadow_color = Color(accent.r, accent.g, accent.b, 0.16)
	return style


## --- Arcade : écran de jeu -------------------------------------------------

## Tuile réponse : fond plein coloré, relief clair en haut, ombre teintée.
static func answer_tile(slot_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = slot_color
	style.set_corner_radius_all(UiTokens.RADIUS_MD)
	style.border_width_top = 3
	style.border_color = Color(1, 1, 1, 0.28)
	style.shadow_color = Color(slot_color.r, slot_color.g, slot_color.b, 0.35)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 5)
	style.content_margin_left = 14
	style.content_margin_top = 14
	style.content_margin_right = 14
	style.content_margin_bottom = 14
	style.anti_aliasing = true
	return style


## État après réponse : bonne (vert) / mauvaise (rouge), plein et net.
static func answer_tile_state(color: Color) -> StyleBoxFlat:
	var style := answer_tile(color)
	style.border_width_top = 0
	style.border_width_bottom = 4
	style.border_color = Color(1, 1, 1, 0.5)
	style.shadow_color = Color(color.r, color.g, color.b, 0.5)
	style.shadow_size = 18
	return style


## Remplissage de la barre de timer selon le temps restant (1..0).
static func timer_fill_for_ratio(ratio: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.timer_color_for_ratio(ratio)
	style.set_corner_radius_all(UiTokens.RADIUS_SM)
	return style


## Fond de la pastille combo, teinté selon le palier.
static func combo_badge(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, 0.16)
	style.set_corner_radius_all(UiTokens.RADIUS_PILL)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(color.r, color.g, color.b, 0.55)
	style.content_margin_left = 14
	style.content_margin_top = 4
	style.content_margin_right = 14
	style.content_margin_bottom = 4
	return style
