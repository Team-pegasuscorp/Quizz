class_name UiTokens
extends RefCounted

## Minimal Premium — light canvas, dark type, white cards, tab accents.

const FEEDBACK_TIMEOUT := Color(0.941, 0.706, 0.161, 1)
const FEEDBACK_CORRECT := Color(0.18, 0.78, 0.52, 1)
const FEEDBACK_WRONG := Color(1.0, 0.31, 0.427, 1)
const NEUTRAL := Color(1, 1, 1, 1)

const BG_CREAM := Color(1.0, 1.0, 1.0, 1)
const BG_MINT := Color(0.96, 0.97, 0.98, 1)
const INK := Color(0.12, 0.13, 0.15, 1)
const INK_MUTED := Color(0.55, 0.57, 0.6, 1)
const TEXT_ON_ACCENT := Color(1, 1, 1, 1)

const ACCENT_HOME := Color(0.071, 0.769, 0.722, 1)             # teal
const ACCENT_LEADERBOARD := Color(0.941, 0.706, 0.161, 1)      # gold
const ACCENT_QUIZ := Color(0.36, 0.75, 1.0, 1)                 # light blue #5CBFFF
const ACCENT_QUIZ_DEEP := Color(0.18, 0.56, 0.88, 1)           # #2E8FE0
const ACCENT_SOCIAL := Color(0.91, 0.365, 0.604, 1)            # magenta
const ACCENT_PROFILE := Color(0.42, 0.361, 1.0, 1)             # violet
const ACCENT_XP := Color(0.071, 0.769, 0.722, 1)               # cyan progress

## Indexed like ScenePaths.Tab: HOME, QUIZ, SOCIAL, LEADERBOARD, PROFILE
const TAB_ACCENTS: Array[Color] = [
	ACCENT_HOME,
	ACCENT_QUIZ,
	ACCENT_SOCIAL,
	ACCENT_LEADERBOARD,
	ACCENT_PROFILE,
]

const CARD_BG := Color(1, 1, 1, 1)
const CARD_BG_SOFT := Color(0.97, 0.98, 0.99, 1)
const CARD_BORDER := Color(0, 0, 0, 0)
const CARD_SHADOW := Color(0.45, 0.62, 0.78, 0.1)
const TEXT_MUTED := INK_MUTED

## Rayons — une seule échelle pour toute l'app.
const RADIUS_SM: int = 14
const RADIUS_MD: int = 22
const RADIUS_LG: int = 30
const RADIUS_PILL: int = 999
const CARD_RADIUS: int = RADIUS_LG

## Réponses arcade — 4 teintes vives à luminance proche, texte blanc lisible.
## Indexé par position du bouton (0..3).
const ANSWER_SLOTS: Array[Color] = [
	Color(0.96, 0.62, 0.13, 1),   # ambre
	Color(0.92, 0.31, 0.43, 1),   # corail
	Color(0.13, 0.71, 0.61, 1),   # turquoise
	Color(0.40, 0.44, 0.93, 1),   # indigo
]

## Timer — rampe d'urgence.
const TIMER_CALM := ACCENT_QUIZ
const TIMER_WARN := Color(0.96, 0.66, 0.13, 1)
const TIMER_DANGER := Color(0.95, 0.27, 0.33, 1)
const TIMER_WARN_RATIO: float = 0.45
const TIMER_DANGER_RATIO: float = 0.25

## Combo — paliers visuels (couleur + taille de police du badge).
const COMBO_TIER_LOW := ACCENT_QUIZ
const COMBO_TIER_MID := Color(0.96, 0.66, 0.13, 1)
const COMBO_TIER_HIGH := Color(0.92, 0.31, 0.43, 1)

const HEADER_BANNER_BG := Color(0.16, 0.52, 0.86, 1)           # slightly deeper than Quiz FAB #5CBFFF
const HEADER_BANNER_FG := TEXT_ON_ACCENT
const HEADER_BANNER_HEIGHT: float = 112.0
const HEADER_SHELL_HEIGHT: float = 112.0
const HEADER_SHELL_MARGIN_H: int = 0
const HEADER_SHELL_MARGIN_TOP: int = 0
const HEADER_SHELL_MARGIN_BOTTOM: int = 0
const HEADER_BAR_RADIUS: int = 0
const HEADER_LOGO_SIZE: float = 48.0
const HEADER_TITLE_SIZE: int = 28
const HEADER_SETTINGS_SIZE: float = 56.0
const HEADER_SETTINGS_ICON_SIZE: int = 34
const APP_LOGO_PATH := "res://assets/ui/logo_app.svg"

const BOTTOM_NAV_HEIGHT: float = 96.0
const BOTTOM_NAV_TOTAL_HEIGHT: float = 188.0
const BOTTOM_NAV_BG := Color(1, 1, 1, 1)
const BOTTOM_NAV_BORDER := Color(0, 0, 0, 0)
const BOTTOM_NAV_GLOW := Color(0.45, 0.62, 0.78, 0.12)
const BOTTOM_NAV_CORNER_RADIUS: int = 32
const BOTTOM_NAV_ICON_SIZE: int = 28
const BOTTOM_NAV_INDICATOR_HEIGHT: float = 3.0
const BOTTOM_NAV_PILL_INSET: float = 6.0
const BOTTOM_NAV_PILL_HEIGHT: float = 80.0
const BOTTOM_NAV_PILL_DURATION: float = 0.2
const SECONDARY_NAV_ICON_SIZE: int = 44
const SECONDARY_NAV_LABEL_SIZE_ACTIVE: int = 17
const SECONDARY_NAV_LABEL_SIZE_INACTIVE: int = 16
const SECONDARY_NAV_INACTIVE_ALPHA: float = 1.0
const QUIZ_FAB_SIZE: float = 128.0
const QUIZ_FAB_LIFT: float = 56.0
const QUIZ_FAB_ICON_SIZE: int = 66
const QUIZ_FAB_LABEL_SIZE: int = 18
const QUIZ_FAB_SHADOW_SIZE: int = 14
const QUIZ_FAB_GLOW_SIZE: float = 140.0
const QUIZ_FAB_RING_SIZE: float = 144.0
const QUIZ_FAB_CORNER_RADIUS: int = 64
const QUIZ_FAB_INACTIVE_ALPHA: float = 0.94
const QUIZ_FAB_PRESS_SCALE: float = 0.92
const QUIZ_FAB_PRESS_DURATION: float = 0.08
const QUIZ_FAB_GLOW_DURATION: float = 1.8
const QUIZ_FAB_GLOW_COLOR := Color(0.36, 0.75, 1.0, 0.12)
const QUIZ_FAB_GLOW_ALPHA_MIN: float = 0.10
const QUIZ_FAB_GLOW_ALPHA_MAX: float = 0.22
const TAB_SWIPE_THRESHOLD: float = 80.0
const TAB_SWIPE_DRAG_LOCK: float = 14.0
const TAB_SWIPE_DURATION: float = 0.24
const TAB_INACTIVE_COLOR := Color(0.55, 0.57, 0.6, 1)
const TAB_ACTIVE_COLOR := Color(0.12, 0.13, 0.15, 1)
const TAB_ICON_PATHS: Array[String] = [
	"res://assets/ui/icon_tab_home.svg",
	"res://assets/ui/icon_tab_quiz.svg",
	"res://assets/ui/icon_tab_multiplayer.svg",
	"res://assets/ui/icon_tab_leaderboard.svg",
	"res://assets/ui/icon_tab_profile.svg",
]

const PROFILE_CARD_RADIUS: int = 22
const PROFILE_CARD_BG := CARD_BG
const PROFILE_CARD_BORDER := CARD_BORDER
const PROFILE_STAT_ACCENT := ACCENT_PROFILE
const PROFILE_MASTERY_BAR_BG := Color(0.12, 0.13, 0.15, 0.08)
const PROFILE_MASTERY_BAR_FILL := ACCENT_XP
const PROFILE_BADGE_LOCKED := Color(0.55, 0.58, 0.66, 0.4)
const PROFILE_AVATAR_DISPLAY: float = 108.0

const ANSWER_TILE_MIN: float = 140.0
const ANSWER_TILE_MAX: float = 200.0
const BUTTON_PRESS_SCALE: float = 0.94
const PROFILE_AVATAR_SIZE: int = 256
const DEFAULT_PLAYER_NAME: String = "Player"
const MAX_PLAYER_NAME_LENGTH: int = 24

const PAGE_MARGIN: int = 22
const SECTION_GAP: int = 18


static func accent_for_tab(tab_id: int) -> Color:
	if tab_id < 0 or tab_id >= TAB_ACCENTS.size():
		return ACCENT_QUIZ
	return TAB_ACCENTS[tab_id]


static func accent_for_category(category_id: String) -> Color:
	match category_id:
		"sport":
			return ACCENT_HOME
		"cinema":
			return ACCENT_SOCIAL
		"history":
			return ACCENT_LEADERBOARD
		_:
			return ACCENT_PROFILE


static func answer_slot_color(index: int) -> Color:
	if index < 0 or index >= ANSWER_SLOTS.size():
		return ACCENT_QUIZ
	return ANSWER_SLOTS[index]


## Couleur + taille de police du badge combo pour une valeur donnée.
static func combo_tier(combo: int) -> Dictionary:
	if combo >= 6:
		return {"color": COMBO_TIER_HIGH, "font_size": 26}
	if combo >= 4:
		return {"color": COMBO_TIER_MID, "font_size": 23}
	return {"color": COMBO_TIER_LOW, "font_size": 20}


## Couleur de remplissage du timer selon le ratio de temps restant (1..0).
static func timer_color_for_ratio(ratio: float) -> Color:
	if ratio <= TIMER_DANGER_RATIO:
		return TIMER_DANGER
	if ratio <= TIMER_WARN_RATIO:
		return TIMER_WARN
	return TIMER_CALM
