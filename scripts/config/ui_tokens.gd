class_name UiTokens
extends RefCounted

## Fableris UI tokens and layout numbers. Adjust colors and sizes here.

const FEEDBACK_TIMEOUT := Color(0.9098, 0.8314, 0.6275)
const FEEDBACK_CORRECT := Color(0.4275, 0.9804, 0.7373)
const FEEDBACK_WRONG := Color(0.9804, 0.4275, 0.5608)
const NEUTRAL := Color(1, 1, 1, 1)

const ANSWER_TILE_MIN: float = 140.0
const ANSWER_TILE_MAX: float = 200.0
const ANSWER_GRID_MARGIN: float = 56.0
const ANSWER_BLINK_COUNT: int = 3
const ANSWER_BLINK_HALF: float = 0.14
const BUTTON_PRESS_SCALE: float = 0.97

const PROFILE_AVATAR_SIZE: int = 256
const DEFAULT_PLAYER_NAME: String = "Player"
const MAX_PLAYER_NAME_LENGTH: int = 24
