class_name LeaderboardSnapshot
extends RefCounted

const PlayerRanks = preload("res://scripts/profile/player_ranks.gd")
const QuestionLoaderScript = preload("res://scripts/quiz/question_loader.gd")

const RIVAL_NAMES: Array[String] = [
	"Nova", "Kira", "Milo", "Zara", "Theo", "Luna", "Axel", "Iris", "Leo",
]
const USE_DEMO_WHEN_EMPTY: bool = true


static func build(category_filter: String, locale: String) -> Dictionary:
	var filter := _normalize_filter(category_filter)
	var entries: Array[Dictionary] = []

	if USE_DEMO_WHEN_EMPTY and _total_games_played() == 0:
		entries = _demo_entries(filter, locale)
	else:
		SaveManager.ensure_leaderboard_rivals()
		entries = _live_entries(filter, locale)

	entries.sort_custom(_sort_entries)
	for index in range(entries.size()):
		entries[index]["rank"] = index + 1

	var player_rank := 0
	for entry in entries:
		if entry.get("is_player", false):
			player_rank = int(entry.get("rank", 0))
			break

	var podium: Array[Dictionary] = []
	var rest: Array[Dictionary] = []
	for index in range(entries.size()):
		if index < 3:
			podium.append(entries[index])
		else:
			rest.append(entries[index])

	return {
		"entries": entries,
		"podium": podium,
		"rest": rest,
		"player_rank": player_rank,
		"is_demo": USE_DEMO_WHEN_EMPTY and _total_games_played() == 0,
		"filter": filter,
	}


static func available_filters(locale: String) -> Array[Dictionary]:
	var filters: Array[Dictionary] = [
		{"id": "all", "label": _tr("UI_LEADERBOARD_FILTER_ALL")},
	]
	for category in QuestionLoaderScript.get_categories(locale):
		filters.append({
			"id": str(category.get("id", "")),
			"label": str(category.get("name", "")),
		})
	return filters


static func _normalize_filter(category_filter: String) -> String:
	if category_filter.is_empty() or category_filter == "all":
		return "all"
	return category_filter


static func _live_entries(filter: String, locale: String) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	entries.append(_player_entry(filter, locale))
	for rival in SaveManager.leaderboard_rivals:
		if typeof(rival) != TYPE_DICTIONARY:
			continue
		entries.append(_rival_entry(rival, filter, locale))
	return entries


static func _player_entry(filter: String, locale: String) -> Dictionary:
	var score := SaveManager.get_leaderboard_score(filter)
	var level := SaveManager.level
	return {
		"id": "player",
		"name": SaveManager.player_name,
		"score": score,
		"level": level,
		"rank_title_key": PlayerRanks.title_for_level(level),
		"is_player": true,
		"category_id": filter,
		"category_name": _category_label(filter, locale),
	}


static func _rival_entry(rival: Dictionary, filter: String, locale: String) -> Dictionary:
	var scores: Dictionary = rival.get("scores", {})
	var score := int(scores.get(filter, scores.get("all", 0)))
	var level := int(rival.get("level", 1))
	return {
		"id": str(rival.get("id", rival.get("name", "rival"))),
		"name": str(rival.get("name", "Player")),
		"score": score,
		"level": level,
		"rank_title_key": PlayerRanks.title_for_level(level),
		"is_player": false,
		"category_id": filter,
		"category_name": _category_label(filter, locale),
	}


static func _demo_entries(filter: String, locale: String) -> Array[Dictionary]:
	var demo_scores := {
		"all": [620, 580, 540, 510, 470, 430, 390, 360, 330, 300],
		"sport": [590, 550, 520, 480, 450, 410, 380, 350, 320, 290],
		"cinema": [610, 570, 530, 500, 460, 420, 390, 360, 330, 300],
		"history": [600, 560, 525, 490, 455, 415, 385, 355, 325, 295],
	}
	var names := ["Nova", "Kira", "Milo", "Zara", "Theo", "Luna", "Axel", "Iris", "Leo", SaveManager.player_name]
	var scores: Array = demo_scores.get(filter, demo_scores["all"])
	var entries: Array[Dictionary] = []
	for index in range(names.size()):
		var is_player: bool = names[index] == SaveManager.player_name
		var level: int = 4 if is_player else clampi(2 + index % 6, 2, 10)
		entries.append({
			"id": "player" if is_player else "demo_%d" % index,
			"name": names[index],
			"score": int(scores[index]),
			"level": level,
			"rank_title_key": PlayerRanks.title_for_level(level),
			"is_player": is_player,
			"category_id": filter,
			"category_name": _category_label(filter, locale),
		})
	return entries


static func _sort_entries(a: Dictionary, b: Dictionary) -> bool:
	var score_a := int(a.get("score", 0))
	var score_b := int(b.get("score", 0))
	if score_a == score_b:
		return str(a.get("name", "")) < str(b.get("name", ""))
	return score_a > score_b


static func _total_games_played() -> int:
	var total := 0
	for category_id in SaveManager.category_stats.keys():
		total += int(SaveManager.category_stats[category_id].get("games_played", 0))
	return total


static func _category_label(filter: String, locale: String) -> String:
	if filter == "all":
		return _tr("UI_LEADERBOARD_FILTER_ALL")
	for category in QuestionLoaderScript.get_categories(locale):
		if str(category.get("id", "")) == filter:
			return str(category.get("name", filter))
	return filter


static func _tr(key: String) -> String:
	return TranslationServer.translate(key)
