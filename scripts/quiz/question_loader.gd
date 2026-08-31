class_name QuestionLoader
extends RefCounted

const QUESTIONS_DIR: String = "res://data/questions/"
const CATEGORIES_PATH: String = "res://data/categories.json"


static func get_categories(locale: String) -> Array[Dictionary]:
	var parsed: Variant = _load_json(CATEGORIES_PATH)
	if typeof(parsed) != TYPE_DICTIONARY:
		return []

	var result: Array[Dictionary] = []
	for category_id in parsed.keys():
		var entry: Dictionary = parsed[category_id]
		var translations: Dictionary = entry.get("translations", {})
		var locale_block: Dictionary = translations.get(locale, translations.get("en", {}))
		result.append({
			"id": category_id,
			"name": locale_block.get("name", category_id),
			"description": locale_block.get("description", ""),
			"locales": entry.get("locales", ["fr", "en"]),
		})

	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a.get("name", "") < b.get("name", "")
	)
	return result


static func load_questions_for_category(
	category_id: String,
	locale: String,
	count: int
) -> Array[Dictionary]:
	var path: String = "%s%s.json" % [QUESTIONS_DIR, category_id]
	var parsed: Variant = _load_json(path)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("QuestionLoader: invalid question file %s" % path)
		return []

	var raw_questions: Array = parsed.get("questions", [])
	var localized: Array[Dictionary] = []

	for raw in raw_questions:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var question: Dictionary = _localize_question(raw, locale)
		if question.is_empty():
			continue
		localized.append(question)

	localized.shuffle()
	if count > 0 and localized.size() > count:
		return localized.slice(0, count)
	return localized


static func _localize_question(raw: Dictionary, locale: String) -> Dictionary:
	var allowed_locales: Array = raw.get("locales", ["fr", "en"])
	if locale not in allowed_locales:
		return {}

	var translations: Dictionary = raw.get("translations", {})
	var locale_block: Dictionary = translations.get(locale, {})
	if locale_block.is_empty():
		for fallback in ["en", "fr"]:
			if translations.has(fallback):
				locale_block = translations[fallback]
				break

	if locale_block.is_empty():
		return {}

	var choices: Array = locale_block.get("choices", [])
	if choices.size() != 4:
		return {}

	return {
		"id": raw.get("id", ""),
		"category": raw.get("category", ""),
		"difficulty": int(raw.get("difficulty", 1)),
		"text": locale_block.get("text", ""),
		"choices": choices,
		"explanation": locale_block.get("explanation", ""),
		"correct_index": int(raw.get("correct_index", -1)),
	}


static func _load_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		push_error("QuestionLoader: file not found %s" % path)
		return null

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed
