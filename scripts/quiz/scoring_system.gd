class_name ScoringSystem
extends RefCounted

const BASE_POINTS: int = 100
const MIN_SPEED_MULTIPLIER: float = 0.5


static func calculate_points(elapsed_seconds: float, time_limit: float, combo: int) -> int:
	var clamped_elapsed: float = clamp(elapsed_seconds, 0.0, time_limit)
	var speed_ratio: float = 1.0 - (clamped_elapsed / time_limit)
	var speed_multiplier: float = max(MIN_SPEED_MULTIPLIER, speed_ratio)
	var combo_multiplier: float = 1.0 + max(combo - 1, 0) * 0.1
	return int(round(BASE_POINTS * speed_multiplier * combo_multiplier))
