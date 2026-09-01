extends Control

const QuestionLoaderScript = preload("res://scripts/quiz/question_loader.gd")
const ScenePaths = preload("res://scripts/config/scene_paths.gd")
const PressScaleUtil = preload("res://scripts/ui/press_scale.gd")

@onready var title_label: Label = %TitleLabel
@onready var category_list: ItemList = %CategoryList
@onready var back_button: Button = %BackButton
@onready var description_label: Label = %DescriptionLabel
@onready var start_button: Button = %StartButton

var categories: Array[Dictionary] = []


func _ready() -> void:
	_apply_translations()
	_load_categories()
	back_button.pressed.connect(_on_back_pressed)
	start_button.pressed.connect(_on_start_pressed)
	category_list.item_selected.connect(_on_category_selected)
	LocaleManager.locale_changed.connect(_on_locale_changed)
	PressScaleUtil.wire(start_button, self)
	PressScaleUtil.wire(back_button, self)


func _apply_translations() -> void:
	title_label.text = tr("UI_CHOOSE_CATEGORY")
	back_button.text = tr("UI_BACK")
	start_button.text = tr("UI_PLAY")


func _load_categories() -> void:
	categories = QuestionLoaderScript.get_categories(LocaleManager.get_content_locale())
	category_list.clear()

	if categories.is_empty():
		description_label.text = tr("UI_NO_CATEGORIES")
		start_button.disabled = true
		return

	for index in range(categories.size()):
		var category: Dictionary = categories[index]
		category_list.add_item(category.get("name", category.get("id", "")))
		category_list.set_item_metadata(index, category.get("id", ""))

	category_list.select(0)
	_on_category_selected(0)


func _on_category_selected(index: int) -> void:
	if index < 0 or index >= categories.size():
		return
	description_label.text = categories[index].get("description", "")
	start_button.disabled = false


func _on_start_pressed() -> void:
	var selected_items: PackedInt32Array = category_list.get_selected_items()
	if selected_items.is_empty():
		return

	var category_id: String = str(category_list.get_item_metadata(selected_items[0]))
	GameManager.start_round(category_id)

	if not GameManager.has_questions():
		description_label.text = tr("UI_EMPTY_QUESTIONS")
		return

	get_tree().change_scene_to_file(ScenePaths.QUIZ_GAME)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(ScenePaths.MAIN_MENU)


func _on_locale_changed(_locale: String) -> void:
	_apply_translations()
	_load_categories()
