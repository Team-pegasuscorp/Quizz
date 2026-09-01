class_name UiTokens
extends RefCounted

## QuizUp-inspired UI tokens.

const FEEDBACK_TIMEOUT := Color(1.0, 0.7922, 0.0118, 1)       # #FFC107
const FEEDBACK_CORRECT := Color(0.4, 0.7333, 0.4157, 1)     # #66BB6A
const FEEDBACK_WRONG := Color(0.9373, 0.3255, 0.3137, 1)      # #EF5350
const NEUTRAL := Color(1, 1, 1, 1)

const BRAND_BLUE := Color(0.098, 0.4627, 0.8235, 1)          # #1976D2
const BRAND_BLUE_DARK := Color(0.051, 0.2784, 0.6314, 1)      # #0D47A1
const BRAND_CYAN := Color(0.0, 0.7373, 0.8314, 1)             # #00BCD4
const BRAND_ORANGE := Color(1.0, 0.5961, 0.0, 1)              # #FF9800

const HEADER_BANNER_BG := Color(0.098, 0.4627, 0.8235, 1)
const HEADER_BANNER_FG := Color(1, 1, 1, 1)
const HEADER_BANNER_HEIGHT: float = 100.0
const HEADER_SETTINGS_SIZE: float = 80.0
const HEADER_SETTINGS_ICON_SIZE: int = 72

const BOTTOM_NAV_HEIGHT: float = 72.0
const BOTTOM_NAV_TOTAL_HEIGHT: float = 120.0
const BOTTOM_NAV_BG := Color(0.118, 0.122, 0.133, 0.98)      # dark grey
const BOTTOM_NAV_ICON_SIZE: int = 24
const BOTTOM_NAV_INDICATOR_HEIGHT: float = 3.0
const SECONDARY_NAV_ICON_SIZE: int = 22
const SECONDARY_NAV_INACTIVE_ALPHA: float = 0.58
const QUIZ_FAB_SIZE: float = 92.0
const QUIZ_FAB_LIFT: float = 26.0
const QUIZ_FAB_ICON_SIZE: int = 38
const QUIZ_FAB_SHADOW_SIZE: int = 16
const QUIZ_FAB_GLOW_SIZE: float = 116.0
const QUIZ_FAB_CORNER_RADIUS: int = 10
const QUIZ_FAB_INACTIVE_ALPHA: float = 0.82
const QUIZ_FAB_PRESS_SCALE: float = 0.94
const QUIZ_FAB_PRESS_DURATION: float = 0.08
const QUIZ_FAB_GLOW_DURATION: float = 1.6
const QUIZ_FAB_GLOW_COLOR := Color(1.0, 0.5961, 0.0, 0.45)
const TAB_SWIPE_THRESHOLD: float = 80.0
const TAB_SWIPE_DRAG_LOCK: float = 14.0
const TAB_SWIPE_DURATION: float = 0.28
const TAB_INACTIVE_COLOR := Color(0.5647, 0.7922, 0.9765, 0.72)
const TAB_ACTIVE_COLOR := Color(1.0, 1.0, 1.0, 1)
const TAB_ICON_PATHS: Array[String] = [
	"res://assets/ui/icon_tab_home.svg",
	"res://assets/ui/icon_tab_quiz.svg",
	"res://assets/ui/icon_tab_multiplayer.svg",
	"res://assets/ui/icon_tab_leaderboard.svg",
	"res://assets/ui/icon_tab_profile.svg",
]

const PROFILE_CARD_RADIUS: int = 16
const PROFILE_CARD_BG := Color(1, 1, 1, 0.1)
const PROFILE_CARD_BORDER := Color(1, 1, 1, 0.18)
const PROFILE_STAT_ACCENT := Color(0.0, 0.7373, 0.8314, 1)
const PROFILE_MASTERY_BAR_BG := Color(0.0431, 0.1529, 0.3137, 0.85)
const PROFILE_MASTERY_BAR_FILL := Color(1.0, 0.5961, 0.0, 1)
const PROFILE_BADGE_LOCKED := Color(0.55, 0.65, 0.78, 0.45)

const ANSWER_TILE_MIN: float = 140.0
const ANSWER_TILE_MAX: float = 200.0
const BUTTON_PRESS_SCALE: float = 0.97
const PROFILE_AVATAR_SIZE: int = 256
const DEFAULT_PLAYER_NAME: String = "Player"
const MAX_PLAYER_NAME_LENGTH: int = 24
