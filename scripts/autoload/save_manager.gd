extends Node

const UiTokens = preload("res://scripts/config/ui_tokens.gd")

const SAVE_PATH: String = "user://save.json"
const PROFILE_AVATAR_PATH: String = "user://profile_avatar.png"
const DEFAULT_AVATAR_PATH: String = "res://assets/ui/default_avatar.svg"

var player_name: String = UiTokens.DEFAULT_PLAYER_NAME
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


func set_player_name(name: String) -> void:
	var trimmed := name.strip_edges()
	player_name = trimmed if not trimmed.is_empty() else UiTokens.DEFAULT_PLAYER_NAME
	save_data()


func get_xp_for_next_level() -> int:
	return _xp_for_next_level()


func get_xp_progress_ratio() -> float:
	var needed := _xp_for_next_level()
	if needed <= 0:
		return 0.0
	return clampf(float(xp) / float(needed), 0.0, 1.0)


func has_custom_avatar() -> bool:
	return FileAccess.file_exists(PROFILE_AVATAR_PATH)


func get_profile_avatar_texture() -> Texture2D:
	if has_custom_avatar():
		var image := Image.load_from_file(PROFILE_AVATAR_PATH)
		if image != null:
			return ImageTexture.create_from_image(image)
	if ResourceLoader.exists(DEFAULT_AVATAR_PATH):
		return load(DEFAULT_AVATAR_PATH) as Texture2D
	return null


func set_profile_avatar_from_file(source_path: String) -> bool:
	var image := Image.new()
	if image.load(source_path) != OK:
		return false
	image.resize(UiTokens.PROFILE_AVATAR_SIZE, UiTokens.PROFILE_AVATAR_SIZE, Image.INTERPOLATE_LANCZOS)
	if image.save_png(PROFILE_AVATAR_PATH) != OK:
		return false
	save_data()
	return true


func clear_profile_avatar() -> void:
	if FileAccess.file_exists(PROFILE_AVATAR_PATH):
		DirAccess.remove_absolute(PROFILE_AVATAR_PATH)
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
