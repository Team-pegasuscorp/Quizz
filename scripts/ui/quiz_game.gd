extends Control

const UiTokens = preload("res://scripts/config/ui_tokens.gd")
const ScenePaths = preload("res://scripts/config/scene_paths.gd")
const PressScaleUtil = preload("res://scripts/ui/press_scale.gd")

@onready var progress_label: Label = %ProgressLabel
@onready var score_label: Label = %ScoreLabel
@onready var combo_label: Label = %ComboLabel
@onready var question_label: Label = %QuestionLabel
@onready var feedback_label: Label = %FeedbackLabel
@onready var timer_bar: ProgressBar = %TimerBar
@onready var answers_grid: GridContainer = %AnswersGrid
@onready var answer_buttons: Array[Button] = [
	%AnswerButton1,
	%AnswerButton2,
	%AnswerButton3,
	%AnswerButton4,
]

var time_remaining: float = 0.0
var question_start_time: float = 0.0
var accepting_input: bool = true
var _blink_tweens: Array[Tween] = []


func _ready() -> void:
	if not GameManager.has_questions():
		get_tree().change_scene_to_file(ScenePaths.CATEGORY_SELECT)
		return

	for index in range(answer_buttons.size()):
		var button: Button = answer_buttons[index]
		PressScaleUtil.wire(button, self)
		button.pressed.connect(_on_answer_pressed.bind(index))

	resized.connect(_update_answer_tile_sizes)
	answers_grid.resized.connect(_update_answer_tile_sizes)
	call_deferred("_update_answer_tile_sizes")
	_show_current_question()


func _update_answer_tile_sizes() -> void:
	if answers_grid == null:
		return
	var separation: float = float(answers_grid.get_theme_constant("h_separation"))
	var available_width: float = answers_grid.size.x
	if available_width <= 1.0:
		available_width = size.x - UiTokens.ANSWER_GRID_MARGIN
	var side: float = floorf((available_width - separation) * 0.5)
	side = clampf(side, UiTokens.ANSWER_TILE_MIN, UiTokens.ANSWER_TILE_MAX)
	var tile_size := Vector2(side, side)
	for button in answer_buttons:
		button.custom_minimum_size = tile_size
	answers_grid.custom_minimum_size = Vector2(side * 2.0 + separation, side * 2.0 + separation)


func _process(delta: float) -> void:
	if not accepting_input:
		return

	time_remaining -= delta
	timer_bar.value = (time_remaining / GameManager.QUESTION_TIME_SECONDS) * 100.0

	if time_remaining <= 0.0:
		_submit_answer(-1)


func _show_current_question() -> void:
	_stop_answer_blinks()
	var question: Dictionary = GameManager.get_current_question()
	if question.is_empty():
		_finish_quiz()
		return

	progress_label.text = "%s %s" % [tr("UI_QUESTION"), GameManager.get_progress_label()]
	score_label.text = "%s: %d" % [tr("UI_SCORE"), GameManager.score]
	combo_label.text = "%s: x%d" % [tr("UI_COMBO"), max(GameManager.combo, 1)]
	question_label.text = question.get("text", "")
	feedback_label.text = ""
	feedback_label.modulate = UiTokens.NEUTRAL

	var choices: Array = question.get("choices", [])
	for index in range(answer_buttons.size()):
		var button: Button = answer_buttons[index]
		button.modulate = UiTokens.NEUTRAL
		if index < choices.size():
			button.text = str(choices[index])
			button.visible = true
			button.disabled = false
		else:
			button.visible = false

	time_remaining = GameManager.QUESTION_TIME_SECONDS
	question_start_time = Time.get_ticks_msec() / 1000.0
	timer_bar.value = 100.0
	accepting_input = true


func _on_answer_pressed(selected_index: int) -> void:
	if not accepting_input:
		return
	_submit_answer(selected_index)


func _submit_answer(selected_index: int) -> void:
	if not accepting_input:
		return
	accepting_input = false

	for button in answer_buttons:
		button.disabled = true

	var question: Dictionary = GameManager.get_current_question()
	var correct_index: int = int(question.get("correct_index", -1))
	var elapsed: float = (Time.get_ticks_msec() / 1000.0) - question_start_time
	var result: Dictionary = GameManager.submit_answer(selected_index, elapsed)
	_show_feedback(result, selected_index, correct_index)

	await get_tree().create_timer(1.2).timeout

	if result.get("finished", false):
		_finish_quiz()
	else:
		_show_current_question()


func _show_feedback(result: Dictionary, selected_index: int, correct_index: int) -> void:
	if result.get("is_timeout", false):
		feedback_label.text = tr("UI_TIME_UP")
		feedback_label.modulate = UiTokens.FEEDBACK_TIMEOUT
	elif result.get("is_correct", false):
		feedback_label.text = "%s +%d" % [tr("UI_CORRECT"), result.get("points", 0)]
		feedback_label.modulate = UiTokens.FEEDBACK_CORRECT
	else:
		feedback_label.text = tr("UI_WRONG")
		feedback_label.modulate = UiTokens.FEEDBACK_WRONG

	score_label.text = "%s: %d" % [tr("UI_SCORE"), GameManager.score]
	combo_label.text = "%s: x%d" % [tr("UI_COMBO"), max(GameManager.combo, 1)]

	if correct_index >= 0 and correct_index < answer_buttons.size():
		_blink_answer(answer_buttons[correct_index], UiTokens.FEEDBACK_CORRECT)

	if (
		selected_index >= 0
		and selected_index < answer_buttons.size()
		and selected_index != correct_index
	):
		_blink_answer(answer_buttons[selected_index], UiTokens.FEEDBACK_WRONG)


func _blink_answer(button: Button, color: Color) -> void:
	var tween := create_tween()
	_blink_tweens.append(tween)
	tween.set_loops(UiTokens.ANSWER_BLINK_COUNT)
	tween.tween_property(button, "modulate", color, UiTokens.ANSWER_BLINK_HALF)
	tween.tween_property(button, "modulate", UiTokens.NEUTRAL, UiTokens.ANSWER_BLINK_HALF)
	tween.finished.connect(func() -> void:
		if is_instance_valid(button):
			button.modulate = color
	)


func _stop_answer_blinks() -> void:
	for tween in _blink_tweens:
		if tween != null and tween.is_valid():
			tween.kill()
	_blink_tweens.clear()
	for button in answer_buttons:
		if is_instance_valid(button):
			button.modulate = UiTokens.NEUTRAL


func _finish_quiz() -> void:
	_stop_answer_blinks()
	GameManager.finish_round()
	get_tree().change_scene_to_file(ScenePaths.RESULTS)
