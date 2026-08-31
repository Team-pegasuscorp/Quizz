extends Node

const SAVE_PATH: String = "user://save.json"

var player_name: String = "Player"
var preferred_locale: String = ""
var level: int = 1
var xp: int = 0
var category_stats: Dictionary = {}


func _ready() -> void:
	load_data()


func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	player_name = parsed.get("player_name", player_name)
	preferred_locale = parsed.get("preferred_locale", preferred_locale)
	level = int(parsed.get("level", level))
	xp = int(parsed.get("xp", xp))
	category_stats = parsed.get("category_stats", category_stats)


func save_data() -> void:
	var data := {
		"player_name": player_name,
		"preferred_locale": preferred_locale,
		"level": level,
		"xp": xp,
		"category_stats": category_stats,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: unable to write save file")
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func get_preferred_locale() -> String:
	return preferred_locale


func set_preferred_locale(locale: String) -> void:
	preferred_locale = locale
	save_data()


func record_match_result(category_id: String, score: int, correct_count: int, total_count: int) -> void:
	if not category_stats.has(category_id):
		category_stats[category_id] = {
			"games_played": 0,
			"best_score": 0,
			"total_correct": 0,
			"total_questions": 0,
		}

	var stats: Dictionary = category_stats[category_id]
	stats["games_played"] = int(stats.get("games_played", 0)) + 1
	stats["best_score"] = max(int(stats.get("best_score", 0)), score)
	stats["total_correct"] = int(stats.get("total_correct", 0)) + correct_count
	stats["total_questions"] = int(stats.get("total_questions", 0)) + total_count
	category_stats[category_id] = stats

	var gained_xp: int = correct_count * 10 + score / 10
	add_xp(gained_xp)
	save_data()


func add_xp(amount: int) -> void:
	xp += amount
	while xp >= _xp_for_next_level():
		xp -= _xp_for_next_level()
		level += 1


func get_category_stats(category_id: String) -> Dictionary:
	return category_stats.get(category_id, {
		"games_played": 0,
		"best_score": 0,
		"total_correct": 0,
		"total_questions": 0,
	})


func _xp_for_next_level() -> int:
	return 100 + (level - 1) * 25
