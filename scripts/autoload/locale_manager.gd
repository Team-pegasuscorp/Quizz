extends Node

const SUPPORTED_LOCALES: Array[String] = ["fr", "en"]
const DEFAULT_LOCALE: String = "fr"
const TRANSLATION_PATHS: Array[String] = [
	"res://locale/ui.en.translation",
	"res://locale/ui.fr.translation",
]

var current_locale: String = DEFAULT_LOCALE

signal locale_changed(locale: String)


func _ready() -> void:
	_load_translation_resources()
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


func _load_translation_resources() -> void:
	# Exported Android builds ship .translation files, not ui.csv (source only).
	for path in TRANSLATION_PATHS:
		if not ResourceLoader.exists(path):
			push_error("LocaleManager: missing translation resource %s" % path)
			continue
		var translation: Translation = load(path) as Translation
		if translation == null:
			push_error("LocaleManager: failed to load %s" % path)
			continue
		TranslationServer.add_translation(translation)
