extends Node

const GameRules = preload("res://scripts/config/game_rules.gd")
const UiTokens = preload("res://scripts/config/ui_tokens.gd")

const SAVE_PATH: String = "user://save.json"
const PROFILE_AVATAR_PATH: String = "user://profile_avatar.png"
const DEFAULT_AVATAR_PATH: String = "res://assets/ui/default_avatar.svg"

var player_name: String = UiTokens.DEFAULT_PLAYER_NAME
var preferred_locale: String = ""
var level: int = 1
var xp: int = 0
var category_stats: Dictionary = {}
var wins: int = 0
var losses: int = 0


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
	wins = int(parsed.get("wins", wins))
	losses = int(parsed.get("losses", losses))


func save_data() -> void:
	var data := {
		"player_name": player_name,
		"preferred_locale": preferred_locale,
		"level": level,
		"xp": xp,
		"category_stats": category_stats,
		"wins": wins,
		"losses": losses,
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


func get_games_played() -> int:
	return wins + losses


func get_win_rate_percent() -> float:
	var total := get_games_played()
	if total <= 0:
		return 0.0
	return float(wins) / float(total) * 100.0


func get_favorite_category_id() -> String:
	var favorite_id := ""
	var favorite_count := 0
	for category_id in category_stats.keys():
		var played: int = int(category_stats[category_id].get("games_played", 0))
		if played > favorite_count:
			favorite_count = played
			favorite_id = str(category_id)
	return favorite_id


func has_custom_avatar() -> bool:
	return FileAccess.file_exists(PROFILE_AVATAR_PATH)


func get_profile_avatar_texture() -> Texture2D:
	if has_custom_avatar():
		var image := Image.load_from_file(PROFILE_AVATAR_PATH)
		if image != null:
			return ImageTexture.create_from_image(image)
	return load(DEFAULT_AVATAR_PATH) as Texture2D


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
		category_stats[category_id] = _empty_category_stats()

	var stats: Dictionary = category_stats[category_id]
	stats["games_played"] = int(stats.get("games_played", 0)) + 1
	stats["best_score"] = max(int(stats.get("best_score", 0)), score)
	stats["total_correct"] = int(stats.get("total_correct", 0)) + correct_count
	stats["total_questions"] = int(stats.get("total_questions", 0)) + total_count
	category_stats[category_id] = stats

	if GameRules.is_match_win(correct_count, total_count):
		wins += 1
	else:
		losses += 1

	add_xp(GameRules.xp_for_match(correct_count, score))
	save_data()


func add_xp(amount: int) -> void:
	xp += amount
	while xp >= GameRules.xp_for_next_level(level):
		xp -= GameRules.xp_for_next_level(level)
		level += 1


func get_category_stats(category_id: String) -> Dictionary:
	return category_stats.get(category_id, _empty_category_stats())


func _empty_category_stats() -> Dictionary:
	return {
		"games_played": 0,
		"best_score": 0,
		"total_correct": 0,
		"total_questions": 0,
	}
