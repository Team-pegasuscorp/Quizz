class_name UiTokens
extends RefCounted

## BrainUp brand — dark neon, FR/EN trivia.

const FEEDBACK_TIMEOUT := Color(1.0, 0.831, 0.0, 1)           # #FFD400
const FEEDBACK_CORRECT := Color(0.0, 0.831, 1.0, 1)           # #00D4FF
const FEEDBACK_WRONG := Color(1.0, 0.302, 1.0, 1)             # #FF4DFF
const NEUTRAL := Color(1, 1, 1, 1)

const BG_DEEP := Color(0.027, 0.039, 0.078, 1)                # #070A14
const BG_NAVY := Color(0.071, 0.094, 0.18, 1)                 # #12182E
const INK := Color(1, 1, 1, 1)
const INK_MUTED := Color(0.72, 0.76, 0.88, 0.78)
const TEXT_ON_ACCENT := Color(1, 1, 1, 1)

const BRAND_CYAN := Color(0.0, 0.831, 1.0, 1)                 # #00D4FF
const BRAND_PURPLE := Color(0.482, 0.38, 1.0, 1)              # #7B61FF
const BRAND_PINK := Color(1.0, 0.302, 1.0, 1)                 # #FF4DFF
const BRAND_ORANGE := Color(1.0, 0.604, 0.0, 1)               # #FF9A00
const BRAND_YELLOW := Color(1.0, 0.831, 0.0, 1)               # #FFD400
const BRAND_WHITE := Color(1, 1, 1, 1)

## CTA approximate of pink→orange gradient (StyleBox solid).
const CTA_PRIMARY := Color(1.0, 0.42, 0.55, 1)
const CTA_PRIMARY_HOVER := Color(1.0, 0.52, 0.42, 1)
const CTA_PRIMARY_PRESSED := Color(0.92, 0.32, 0.62, 1)

const ACCENT_HOME := BRAND_CYAN
const ACCENT_LEADERBOARD := BRAND_YELLOW
const ACCENT_QUIZ := BRAND_ORANGE
const ACCENT_QUIZ_DEEP := Color(0.95, 0.45, 0.05, 1)
const ACCENT_SOCIAL := BRAND_PINK
const ACCENT_PROFILE := BRAND_PURPLE
const PROFILE_HERO := BRAND_PURPLE
const ACCENT_XP := BRAND_CYAN

## Indexed like ScenePaths.Tab: HOME, QUIZ, SOCIAL, LEADERBOARD, PROFILE
const TAB_ACCENTS: Array[Color] = [
	ACCENT_HOME,
	ACCENT_QUIZ,
	ACCENT_SOCIAL,
	ACCENT_LEADERBOARD,
	ACCENT_PROFILE,
]

const CARD_BG := Color(0.1, 0.13, 0.24, 0.92)
const CARD_BG_SOFT := Color(0.12, 0.15, 0.28, 0.96)
const CARD_BORDER := Color(1, 1, 1, 0.1)
const CARD_SHADOW := Color(0.0, 0.83, 1.0, 0.12)
const CARD_RADIUS: int = 22
const TEXT_MUTED := INK_MUTED

const BRAND_BLUE := BRAND_CYAN
const BRAND_BLUE_DARK := BG_NAVY

const HEADER_BANNER_BG := Color(0.06, 0.08, 0.16, 0.98)
const HEADER_BANNER_FG := BRAND_WHITE
const HEADER_BANNER_HEIGHT: float = 112.0
const HEADER_SHELL_HEIGHT: float = 112.0
const HEADER_SHELL_MARGIN_H: int = 0
const HEADER_SHELL_MARGIN_TOP: int = 0
const HEADER_SHELL_MARGIN_BOTTOM: int = 0
const HEADER_BAR_RADIUS: int = 0
const HEADER_LOGO_SIZE: float = 56.0
const HEADER_TITLE_SIZE: int = 28
const HEADER_SETTINGS_SIZE: float = 56.0
const HEADER_SETTINGS_ICON_SIZE: int = 34
const APP_LOGO_PATH := "res://assets/branding/brainup-app-icon.png"
const APP_ICON_PATH := "res://assets/branding/brainup-app-icon.png"

const BOTTOM_NAV_HEIGHT: float = 96.0
const BOTTOM_NAV_TOTAL_HEIGHT: float = 188.0
const BOTTOM_NAV_BG := Color(0.05, 0.07, 0.14, 0.98)
const BOTTOM_NAV_BORDER := Color(0.0, 0.83, 1.0, 0.18)
const BOTTOM_NAV_GLOW := Color(0.482, 0.38, 1.0, 0.18)
const BOTTOM_NAV_CORNER_RADIUS: int = 28
const BOTTOM_NAV_ICON_SIZE: int = 28
const BOTTOM_NAV_INDICATOR_HEIGHT: float = 3.0
const BOTTOM_NAV_PILL_INSET: float = 6.0
const BOTTOM_NAV_PILL_HEIGHT: float = 80.0
const BOTTOM_NAV_PILL_DURATION: float = 0.2
const SECONDARY_NAV_ICON_SIZE: int = 44
const SECONDARY_NAV_LABEL_SIZE_ACTIVE: int = 19
const SECONDARY_NAV_LABEL_SIZE_INACTIVE: int = 18
const SECONDARY_NAV_INACTIVE_ALPHA: float = 0.72
const QUIZ_FAB_SIZE: float = 128.0
const QUIZ_FAB_LIFT: float = 56.0
const QUIZ_FAB_ICON_SIZE: int = 66
const QUIZ_FAB_LABEL_SIZE: int = 20
const QUIZ_FAB_SHADOW_SIZE: int = 16
const QUIZ_FAB_GLOW_SIZE: float = 140.0
const QUIZ_FAB_RING_SIZE: float = 144.0
const QUIZ_FAB_CORNER_RADIUS: int = 64
const QUIZ_FAB_INACTIVE_ALPHA: float = 0.9
const QUIZ_FAB_PRESS_SCALE: float = 0.92
const QUIZ_FAB_PRESS_DURATION: float = 0.08
const QUIZ_FAB_GLOW_DURATION: float = 1.8
const QUIZ_FAB_GLOW_COLOR := Color(1.0, 0.604, 0.0, 0.28)
const QUIZ_FAB_GLOW_ALPHA_MIN: float = 0.18
const QUIZ_FAB_GLOW_ALPHA_MAX: float = 0.42
const TAB_SWIPE_THRESHOLD: float = 80.0
const TAB_SWIPE_DRAG_LOCK: float = 14.0
const TAB_SWIPE_DURATION: float = 0.24
const TAB_INACTIVE_COLOR := Color(0.62, 0.68, 0.82, 0.7)
const TAB_ACTIVE_COLOR := Color(1, 1, 1, 1)
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
const PROFILE_STAT_ACCENT := BRAND_CYAN
const PROFILE_MASTERY_BAR_BG := Color(1, 1, 1, 0.08)
const PROFILE_MASTERY_BAR_FILL := BRAND_ORANGE
const PROFILE_BADGE_LOCKED := Color(0.55, 0.58, 0.66, 0.45)
const PROFILE_AVATAR_DISPLAY: float = 88.0
const PROFILE_HERO_HEIGHT: float = 156.0
const PROFILE_XP_OVERLAP: float = 36.0

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
