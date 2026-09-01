class_name GameRules
extends RefCounted

## Central gameplay tuning. Change win rules, XP, and round settings here.

const QUESTIONS_PER_ROUND: int = 7
const QUESTION_TIME_SECONDS: float = 10.0
const XP_PER_CORRECT: int = 10
const XP_SCORE_DIVISOR: int = 10
const XP_BASE_FOR_LEVEL: int = 100
const XP_LEVEL_STEP: int = 25


static func is_match_win(correct_count: int, total_count: int) -> bool:
	if total_count <= 0:
		return false
	return correct_count * 2 > total_count


static func xp_for_match(correct_count: int, score: int) -> int:
	return correct_count * XP_PER_CORRECT + score / XP_SCORE_DIVISOR


static func xp_for_next_level(level: int) -> int:
	return XP_BASE_FOR_LEVEL + (level - 1) * XP_LEVEL_STEP
