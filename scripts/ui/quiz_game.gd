extends Control

@onready var progress_label: Label = %ProgressLabel
@onready var score_label: Label = %ScoreLabel
@onready var combo_label: Label = %ComboLabel
@onready var question_label: Label = %QuestionLabel
@onready var feedback_label: Label = %FeedbackLabel
@onready var timer_bar: ProgressBar = %TimerBar
@onready var answer_buttons: Array[Button] = [
	%AnswerButton1,
	%AnswerButton2,
	%AnswerButton3,
	%AnswerButton4,
]

var time_remaining: float = 0.0
var question_start_time: float = 0.0
var accepting_input: bool = true


func _ready() -> void:
	if not GameManager.has_questions():
		get_tree().change_scene_to_file("res://scenes/category_select.tscn")
		return

	for index in range(answer_buttons.size()):
		answer_buttons[index].pressed.connect(_on_answer_pressed.bind(index))

	_show_current_question()


func _process(delta: float) -> void:
	if not accepting_input:
		return

	time_remaining -= delta
	timer_bar.value = (time_remaining / GameManager.QUESTION_TIME_SECONDS) * 100.0

	if time_remaining <= 0.0:
		_submit_answer(-1)


func _show_current_question() -> void:
	var question: Dictionary = GameManager.get_current_question()
	if question.is_empty():
		_finish_quiz()
		return

	progress_label.text = "%s %s" % [tr("UI_QUESTION"), GameManager.get_progress_label()]
	score_label.text = "%s: %d" % [tr("UI_SCORE"), GameManager.score]
	combo_label.text = "%s: x%d" % [tr("UI_COMBO"), max(GameManager.combo, 1)]
	question_label.text = question.get("text", "")
	feedback_label.text = ""

	var choices: Array = question.get("choices", [])
	for index in range(answer_buttons.size()):
		var button: Button = answer_buttons[index]
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

	var elapsed: float = (Time.get_ticks_msec() / 1000.0) - question_start_time
	var result: Dictionary = GameManager.submit_answer(selected_index, elapsed)
	_show_feedback(result)

	await get_tree().create_timer(1.1).timeout

	if result.get("finished", false):
		_finish_quiz()
	else:
		_show_current_question()


func _show_feedback(result: Dictionary) -> void:
	if result.get("is_timeout", false):
		feedback_label.text = tr("UI_TIME_UP")
		feedback_label.modulate = Color(1.0, 0.7, 0.3)
	elif result.get("is_correct", false):
		feedback_label.text = "%s +%d" % [tr("UI_CORRECT"), result.get("points", 0)]
		feedback_label.modulate = Color(0.4, 1.0, 0.5)
	else:
		feedback_label.text = tr("UI_WRONG")
		feedback_label.modulate = Color(1.0, 0.4, 0.4)

	score_label.text = "%s: %d" % [tr("UI_SCORE"), GameManager.score]
	combo_label.text = "%s: x%d" % [tr("UI_COMBO"), max(GameManager.combo, 1)]


func _finish_quiz() -> void:
	GameManager.finish_round()
	get_tree().change_scene_to_file("res://scenes/results/results_screen.tscn")
