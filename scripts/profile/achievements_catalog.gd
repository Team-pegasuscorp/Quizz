class_name AchievementsCatalog
extends RefCounted


static func all() -> Array[Dictionary]:
	return [
		{"id": "first_match", "title_key": "UI_ACH_FIRST_MATCH", "desc_key": "UI_ACH_FIRST_MATCH_DESC", "icon": "🎯"},
		{"id": "first_win", "title_key": "UI_ACH_FIRST_WIN", "desc_key": "UI_ACH_FIRST_WIN_DESC", "icon": "🏆"},
		{"id": "streak_3", "title_key": "UI_ACH_STREAK_3", "desc_key": "UI_ACH_STREAK_3_DESC", "icon": "🔥"},
		{"id": "ten_matches", "title_key": "UI_ACH_TEN_MATCHES", "desc_key": "UI_ACH_TEN_MATCHES_DESC", "icon": "📚"},
		{"id": "score_500", "title_key": "UI_ACH_SCORE_500", "desc_key": "UI_ACH_SCORE_500_DESC", "icon": "⭐"},
		{"id": "perfect_round", "title_key": "UI_ACH_PERFECT", "desc_key": "UI_ACH_PERFECT_DESC", "icon": "💎"},
		{"id": "level_5", "title_key": "UI_ACH_LEVEL_5", "desc_key": "UI_ACH_LEVEL_5_DESC", "icon": "🛡️"},
		{"id": "category_explorer", "title_key": "UI_ACH_EXPLORER", "desc_key": "UI_ACH_EXPLORER_DESC", "icon": "🧭"},
		{"id": "unbeatable", "title_key": "UI_ACH_UNBEATABLE", "desc_key": "UI_ACH_UNBEATABLE_DESC", "icon": "🏅"},
		{"id": "scientist", "title_key": "UI_ACH_SCIENTIST", "desc_key": "UI_ACH_SCIENTIST_DESC", "icon": "🔬"},
		{"id": "serious", "title_key": "UI_ACH_SERIOUS", "desc_key": "UI_ACH_SERIOUS_DESC", "icon": "🔥"},
		{"id": "expert_level", "title_key": "UI_ACH_EXPERT", "desc_key": "UI_ACH_EXPERT_DESC", "icon": "🎓"},
	]


static func is_unlocked(achievement_id: String, stats: Dictionary) -> bool:
	match achievement_id:
		"first_match":
			return stats.get("games_played", 0) >= 1
		"first_win":
			return stats.get("wins", 0) >= 1
		"streak_3":
			return stats.get("best_win_streak", 0) >= 3
		"ten_matches":
			return stats.get("games_played", 0) >= 10
		"score_500":
			return stats.get("best_score", 0) >= 500
		"perfect_round":
			return stats.get("has_perfect_round", false)
		"level_5":
			return stats.get("level", 1) >= 5
		"category_explorer":
			return stats.get("categories_played", 0) >= 2
		"unbeatable":
			return stats.get("wins", 0) >= 100
		"scientist":
			return stats.get("correct_answers", 0) >= 500
		"serious":
			return stats.get("best_win_streak", 0) >= 10
		"expert_level":
			return stats.get("level", 1) >= 20
	return false
