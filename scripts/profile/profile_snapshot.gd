class_name ProfileSnapshot
extends RefCounted

const QuestionLoaderScript = preload("res://scripts/quiz/question_loader.gd")


## View-model for profile screens. UI reads this instead of SaveManager fields directly.
static func build(locale: String) -> Dictionary:
	var favorite_id: String = SaveManager.get_favorite_category_id()
	return {
		"player_name": SaveManager.player_name,
		"level": SaveManager.level,
		"avatar_texture": SaveManager.get_profile_avatar_texture(),
		"has_custom_avatar": SaveManager.has_custom_avatar(),
		"games_played": SaveManager.get_games_played(),
		"wins": SaveManager.wins,
		"losses": SaveManager.losses,
		"win_rate_percent": SaveManager.get_win_rate_percent(),
		"favorite_category_id": favorite_id,
		"favorite_category_name": _resolve_category_name(favorite_id, locale),
	}


static func _resolve_category_name(category_id: String, locale: String) -> String:
	if category_id.is_empty():
		return ""
	for category in QuestionLoaderScript.get_categories(locale):
		if category.get("id", "") == category_id:
			return str(category.get("name", category_id))
	return category_id
