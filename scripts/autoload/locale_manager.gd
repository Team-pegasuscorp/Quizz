extends Node

const SUPPORTED_LOCALES: Array[String] = ["fr", "en"]
const DEFAULT_LOCALE: String = "en"
const TRANSLATIONS_PATH: String = "res://locale/ui.csv"

var current_locale: String = DEFAULT_LOCALE

signal locale_changed(locale: String)


func _ready() -> void:
	_load_csv_translations(TRANSLATIONS_PATH)
	var saved_locale: String = SaveManager.get_preferred_locale()
	if saved_locale.is_empty():
		_apply_system_locale()
	else:
		set_locale(saved_locale)


func set_locale(locale: String) -> void:
	if locale not in SUPPORTED_LOCALES:
		locale = DEFAULT_LOCALE
	current_locale = locale
	TranslationServer.set_locale(locale)
	SaveManager.set_preferred_locale(locale)
	locale_changed.emit(locale)


func get_content_locale() -> String:
	return current_locale


func get_supported_locales() -> Array[String]:
	return SUPPORTED_LOCALES.duplicate()


func get_locale_display_name(locale: String) -> String:
	match locale:
		"fr":
			return "Français"
		"en":
			return "English"
		_:
			return locale


func _apply_system_locale() -> void:
	var system_locale: String = OS.get_locale().split("_")[0].split("-")[0]
	if system_locale in SUPPORTED_LOCALES:
		set_locale(system_locale)
	else:
		set_locale(DEFAULT_LOCALE)


func _load_csv_translations(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("LocaleManager: unable to open %s" % path)
		return

	var header: PackedStringArray = file.get_csv_line()
	if header.size() < 2:
		push_error("LocaleManager: invalid CSV header in %s" % path)
		return

	var locales: Array[String] = []
	for index in range(1, header.size()):
		locales.append(header[index])

	var translations: Dictionary = {}
	for locale in locales:
		var translation := Translation.new()
		translation.locale = locale
		translations[locale] = translation

	while not file.eof_reached():
		var line: PackedStringArray = file.get_csv_line()
		if line.is_empty() or line[0].is_empty() or line[0] == "keys":
			continue

		var key: String = line[0]
		for index in range(locales.size()):
			var locale: String = locales[index]
			if index + 1 < line.size():
				translations[locale].add_message(key, line[index + 1])

	for locale in locales:
		TranslationServer.add_translation(translations[locale])

	file.close()
