class_name ProfileSnapshot
extends RefCounted

const QuestionLoaderScript = preload("res://scripts/quiz/question_loader.gd")
const PlayerRanks = preload("res://scripts/profile/player_ranks.gd")
const AchievementsCatalog = preload("res://scripts/profile/achievements_catalog.gd")

const USE_DEMO_WHEN_EMPTY: bool = true


static func build_full(locale: String) -> Dictionary:
	var data := _from_save(locale)
	if USE_DEMO_WHEN_EMPTY and data.get("games_played", 0) == 0:
		data = _merge_demo(data, locale)
	data["achievements"] = _build_achievements(data)
	return data


static func _from_save(locale: String) -> Dictionary:
	var games := _count_games()
	return {
		"player_name": SaveManager.player_name,
		"level": SaveManager.level,
		"xp": SaveManager.xp,
		"xp_to_next": SaveManager.get_xp_for_next_level(),
		"xp_progress": SaveManager.get_xp_progress_ratio(),
		"rank_title_key": PlayerRanks.title_for_level(SaveManager.level),
		"avatar_texture": SaveManager.get_profile_avatar_texture(),
		"has_custom_avatar": SaveManager.has_custom_avatar(),
		"games_played": games,
		"wins": int(max(games * 0.55, 0)),
		"losses": int(max(games - games * 0.55, 0)),
		"win_rate_percent": 55.0 if games > 0 else 0.0,
		"correct_answers": _count_correct(),
		"current_win_streak": 0,
		"best_win_streak": 0,
		"best_score": _best_score(),
		"categories": _build_categories(locale),
		"history": [],
		"is_demo": false,
	}


static func _count_games() -> int:
	var total := 0
	for category_id in SaveManager.category_stats.keys():
		total += int(SaveManager.category_stats[category_id].get("games_played", 0))
	return total


static func _count_correct() -> int:
	var total := 0
	for category_id in SaveManager.category_stats.keys():
		total += int(SaveManager.category_stats[category_id].get("total_correct", 0))
	return total


static func _best_score() -> int:
	var best := 0
	for category_id in SaveManager.category_stats.keys():
		best = max(best, int(SaveManager.category_stats[category_id].get("best_score", 0)))
	return best


static func _merge_demo(base: Dictionary, locale: String) -> Dictionary:
	var demo := base.duplicate(true)
	demo["is_demo"] = true
	demo["level"] = 4
	demo["xp"] = 65
	demo["xp_to_next"] = 175
	demo["xp_progress"] = 0.37
	demo["rank_title_key"] = PlayerRanks.title_for_level(4)
	demo["games_played"] = 18
	demo["wins"] = 11
	demo["losses"] = 7
	demo["win_rate_percent"] = 61.1
	demo["correct_answers"] = 84
	demo["current_win_streak"] = 2
	demo["best_win_streak"] = 4
	demo["best_score"] = 620
	demo["categories"] = [
		_make_category_row("sport", locale, 8, 72.0, 2),
		_make_category_row("cinema", locale, 6, 58.0, 3),
		_make_category_row("history", locale, 4, 45.0, 1),
	]
	demo["history"] = [
		_make_history_row("cinema", locale, 540, true, 6, 7, 2),
		_make_history_row("sport", locale, 410, false, 4, 7, 26),
	]
	return demo


static func _build_categories(locale: String) -> Array:
	var rows: Array = []
	for category in QuestionLoaderScript.get_categories(locale):
		var category_id: String = str(category.get("id", ""))
		var stats: Dictionary = SaveManager.get_category_stats(category_id)
		var games: int = int(stats.get("games_played", 0))
		var total_q: int = int(stats.get("total_questions", 0))
		var total_c: int = int(stats.get("total_correct", 0))
		var accuracy := 0.0 if total_q <= 0 else float(total_c) / float(total_q) * 100.0
		var mastery := 0 if games <= 0 else clampi(int(games / 3) + int(accuracy / 30.0), 1, 4)
		rows.append(_make_category_row(category_id, locale, games, accuracy, mastery))
	return rows


static func _make_category_row(category_id: String, locale: String, games: int, accuracy: float, mastery: int) -> Dictionary:
	return {
		"id": category_id,
		"name": _resolve_category_name(category_id, locale),
		"games_played": games,
		"accuracy_percent": accuracy,
		"mastery_level": mastery,
		"mastery_label_key": "UI_MASTERY_%d" % mastery,
		"mastery_progress": clampf(float(games) / 12.0, 0.12, 1.0),
	}


static func _make_history_row(category_id: String, locale: String, score: int, won: bool, correct: int, total: int, age_hours: int) -> Dictionary:
	return {
		"category_id": category_id,
		"category_name": _resolve_category_name(category_id, locale),
		"score": score,
		"won": won,
		"correct_count": correct,
		"total_count": total,
		"age_hours": age_hours,
	}


static func _build_achievements(data: Dictionary) -> Array:
	var unlock_stats := {
		"games_played": data.get("games_played", 0),
		"wins": data.get("wins", 0),
		"best_win_streak": data.get("best_win_streak", 0),
		"best_score": data.get("best_score", 0),
		"has_perfect_round": false,
		"level": data.get("level", 1),
		"categories_played": data.get("categories", []).size(),
	}
	var rows: Array = []
	for achievement in AchievementsCatalog.all():
		rows.append({
			"id": achievement.get("id", ""),
			"title_key": achievement.get("title_key", ""),
			"desc_key": achievement.get("desc_key", ""),
			"icon": achievement.get("icon", "?"),
			"unlocked": AchievementsCatalog.is_unlocked(str(achievement.get("id", "")), unlock_stats),
		})
	return rows


static func _resolve_category_name(category_id: String, locale: String) -> String:
	for category in QuestionLoaderScript.get_categories(locale):
		if category.get("id", "") == category_id:
			return str(category.get("name", category_id))
	return category_id
