extends Control

const ScenePaths = preload("res://scripts/config/scene_paths.gd")
const PressScaleUtil = preload("res://scripts/ui/press_scale.gd")

@onready var score_caption_label: Label = %ScoreCaption
@onready var correct_caption_label: Label = %CorrectCaption
@onready var combo_caption_label: Label = %ComboCaption
@onready var average_caption_label: Label = %AverageCaption
@onready var title_label: Label = %TitleLabel
@onready var score_value_label: Label = %ScoreValueLabel
@onready var correct_value_label: Label = %CorrectValueLabel
@onready var combo_value_label: Label = %ComboValueLabel
@onready var average_value_label: Label = %AverageValueLabel
@onready var play_again_button: Button = %PlayAgainButton
@onready var menu_button: Button = %MenuButton

var summary: Dictionary = {}


func _ready() -> void:
	summary = GameManager.last_summary
	_apply_translations()
	play_again_button.pressed.connect(_on_play_again_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	LocaleManager.locale_changed.connect(_on_locale_changed)
	PressScaleUtil.wire(play_again_button, self)
	PressScaleUtil.wire(menu_button, self)


func _apply_translations() -> void:
	title_label.text = tr("UI_RESULTS")
	score_caption_label.text = tr("UI_FINAL_SCORE")
	correct_caption_label.text = tr("UI_CORRECT_COUNT")
	combo_caption_label.text = tr("UI_BEST_COMBO")
	average_caption_label.text = tr("UI_AVG_TIME")
	score_value_label.text = str(summary.get("score", 0))
	correct_value_label.text = "%d / %d" % [
		summary.get("correct_count", 0),
		summary.get("total_count", 0),
	]
	combo_value_label.text = "x%d" % summary.get("max_combo", 0)
	average_value_label.text = tr("UI_SECONDS").format({
		"value": "%.1f" % summary.get("average_time", 0.0),
	})
	play_again_button.text = tr("UI_PLAY_AGAIN")
	menu_button.text = tr("UI_MAIN_MENU")


func _on_play_again_pressed() -> void:
	GameManager.start_round(summary.get("category_id", ""))
	if GameManager.has_questions():
		get_tree().change_scene_to_file(ScenePaths.QUIZ_GAME)
	else:
		get_tree().change_scene_to_file(ScenePaths.CATEGORY_SELECT)


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(ScenePaths.MAIN_MENU)


func _on_locale_changed(_locale: String) -> void:
	_apply_translations()
