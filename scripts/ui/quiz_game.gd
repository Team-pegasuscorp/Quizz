extends Control

const UiTokens = preload("res://scripts/config/ui_tokens.gd")
const UiStyle = preload("res://scripts/config/ui_style.gd")
const PressScaleUtil = preload("res://scripts/ui/press_scale.gd")
const ScenePaths = preload("res://scripts/config/scene_paths.gd")

const ANSWER_TILE_MAX := 200.0
const ANSWER_TILE_MIN := 120.0
const FEEDBACK_HOLD := 0.8

@onready var progress_label: Label = %ProgressLabel
@onready var score_label: Label = %ScoreLabel
@onready var combo_badge: PanelContainer = %ComboBadge
@onready var combo_value: Label = %ComboValue
@onready var question_label: Label = %QuestionLabel
@onready var feedback_label: Label = %FeedbackLabel
@onready var timer_bar: ProgressBar = %TimerBar
@onready var question_panel: PanelContainer = %QuestionPanel
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

var _in_feedback: bool = false
var _feedback_until: float = 0.0
var _feedback_finished_round: bool = false
var _displayed_score: int = 0
var _timer_tier: int = -1
var _timer_pulse: Tween
var _score_tween: Tween


func _ready() -> void:
	if not GameManager.has_questions():
		ScenePaths.go_to_shell(get_tree(), ScenePaths.Tab.QUIZ)
		return

	for index in range(answer_buttons.size()):
		var button: Button = answer_buttons[index]
		PressScaleUtil.wire(button, self)
		button.pressed.connect(_on_answer_pressed.bind(index))
		_style_answer_button(button, UiTokens.answer_slot_color(index))

	resized.connect(_update_answer_tile_sizes)
	answers_grid.resized.connect(_update_answer_tile_sizes)
	call_deferred("_update_answer_tile_sizes")

	timer_bar.add_theme_stylebox_override("background", UiStyle.progress_bg())
	_apply_timer_fill(1.0, true)
	question_panel.add_theme_stylebox_override("panel", UiStyle.card(UiTokens.ACCENT_QUIZ))
	combo_badge.visible = false
	feedback_label.text = ""

	_displayed_score = 0
	_show_current_question()


func _style_answer_button(button: Button, slot_color: Color) -> void:
	var tile := UiStyle.answer_tile(slot_color)
	var hover := UiStyle.answer_tile(slot_color.lightened(0.08))
	button.add_theme_stylebox_override("normal", tile)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("focus", tile)
	button.add_theme_stylebox_override("disabled", tile)
	var display_font := get_theme_font("font", "QuestionLabel")
	if display_font != null:
		button.add_theme_font_override("font", display_font)
	for key in [
		"font_color", "font_hover_color", "font_pressed_color",
		"font_focus_color", "font_disabled_color",
	]:
		button.add_theme_color_override(key, UiTokens.TEXT_ON_ACCENT)
	button.set_meta("slot_color", slot_color)


func _reset_answer_button(button: Button) -> void:
	button.modulate = UiTokens.NEUTRAL
	button.scale = Vector2.ONE
	button.rotation = 0.0
	_style_answer_button(button, button.get_meta("slot_color", UiTokens.ACCENT_QUIZ))


func _update_answer_tile_sizes() -> void:
	if answers_grid == null:
		return
	var separation: float = float(answers_grid.get_theme_constant("h_separation"))
	var available_width: float = answers_grid.size.x
	if available_width <= 1.0:
		available_width = size.x - 56.0
	var side: float = floorf((available_width - separation) * 0.5)
	side = clampf(side, ANSWER_TILE_MIN, ANSWER_TILE_MAX)
	var tile_size := Vector2(side, side)
	for button in answer_buttons:
		button.custom_minimum_size = tile_size
	answers_grid.custom_minimum_size = Vector2(side * 2.0 + separation, side * 2.0 + separation)


func _process(delta: float) -> void:
	if accepting_input:
		time_remaining -= delta
		var ratio: float = clampf(time_remaining / GameManager.QUESTION_TIME_SECONDS, 0.0, 1.0)
		timer_bar.value = ratio * 100.0
		_apply_timer_fill(ratio, false)
		if time_remaining <= 0.0:
			_submit_answer(-1)
		return

	if _in_feedback and Time.get_ticks_msec() / 1000.0 >= _feedback_until:
		_end_feedback()


func _input(event: InputEvent) -> void:
	if not _in_feedback:
		return
	var tapped: bool = (
		(event is InputEventMouseButton and event.pressed)
		or (event is InputEventScreenTouch and event.pressed)
	)
	if tapped:
		_feedback_until = 0.0
		get_viewport().set_input_as_handled()


func _apply_timer_fill(ratio: float, force: bool) -> void:
	var tier := 0
	if ratio <= UiTokens.TIMER_DANGER_RATIO:
		tier = 2
	elif ratio <= UiTokens.TIMER_WARN_RATIO:
		tier = 1
	if force or tier != _timer_tier:
		_timer_tier = tier
		timer_bar.add_theme_stylebox_override("fill", UiStyle.timer_fill_for_ratio(ratio))
	_set_timer_pulse(tier == 2)


func _set_timer_pulse(active: bool) -> void:
	if active and (_timer_pulse == null or not _timer_pulse.is_valid()):
		_timer_pulse = create_tween().set_loops()
		_timer_pulse.tween_property(timer_bar, "modulate:a", 0.45, 0.24)
		_timer_pulse.tween_property(timer_bar, "modulate:a", 1.0, 0.24)
	elif not active and _timer_pulse != null and _timer_pulse.is_valid():
		_timer_pulse.kill()
		_timer_pulse = null
		timer_bar.modulate.a = 1.0


func _show_current_question() -> void:
	var question: Dictionary = GameManager.get_current_question()
	if question.is_empty():
		_finish_quiz()
		return

	if _score_tween != null and _score_tween.is_valid():
		_score_tween.kill()
	progress_label.text = "%s %s" % [tr("UI_QUESTION"), GameManager.get_progress_label()]
	score_label.text = str(GameManager.score)
	_displayed_score = GameManager.score
	_update_combo_badge(GameManager.combo, false)
	question_label.text = question.get("text", "")
	feedback_label.text = ""
	feedback_label.modulate = UiTokens.NEUTRAL

	var choices: Array = question.get("choices", [])
	for index in range(answer_buttons.size()):
		var button: Button = answer_buttons[index]
		_reset_answer_button(button)
		if index < choices.size():
			button.text = str(choices[index])
			button.visible = true
			button.disabled = false
		else:
			button.visible = false

	time_remaining = GameManager.QUESTION_TIME_SECONDS
	question_start_time = Time.get_ticks_msec() / 1000.0
	timer_bar.value = 100.0
	_apply_timer_fill(1.0, true)
	accepting_input = true
	_animate_question_in()


func _animate_question_in() -> void:
	question_panel.pivot_offset = question_panel.size * 0.5
	question_panel.scale = Vector2(0.97, 0.97)
	question_panel.modulate.a = 0.0
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(question_panel, "modulate:a", 1.0, 0.18)
	tween.tween_property(question_panel, "scale", Vector2.ONE, 0.18)

	for index in range(answer_buttons.size()):
		var button: Button = answer_buttons[index]
		if not button.visible:
			continue
		button.modulate = Color(1, 1, 1, 0)
		var b_tween := create_tween()
		b_tween.tween_interval(0.04 * index)
		b_tween.tween_property(button, "modulate:a", 1.0, 0.16)


func _update_combo_badge(combo: int, animate: bool) -> void:
	if combo < 2:
		combo_badge.visible = false
		return
	var tier: Dictionary = UiTokens.combo_tier(combo)
	combo_badge.visible = true
	combo_value.text = "x%d" % combo
	combo_value.add_theme_font_size_override("font_size", tier["font_size"])
	combo_value.add_theme_color_override("font_color", tier["color"])
	combo_badge.add_theme_stylebox_override("panel", UiStyle.combo_badge(tier["color"]))
	if animate:
		combo_badge.pivot_offset = combo_badge.size * 0.5
		combo_badge.scale = Vector2.ONE * 1.35
		var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(combo_badge, "scale", Vector2.ONE, 0.28)


func _on_answer_pressed(selected_index: int) -> void:
	if not accepting_input:
		return
	_submit_answer(selected_index)


func _submit_answer(selected_index: int) -> void:
	if not accepting_input:
		return
	accepting_input = false
	_set_timer_pulse(false)

	for button in answer_buttons:
		button.disabled = true

	var question: Dictionary = GameManager.get_current_question()
	var correct_index: int = int(question.get("correct_index", -1))
	var elapsed: float = (Time.get_ticks_msec() / 1000.0) - question_start_time
	var result: Dictionary = GameManager.submit_answer(selected_index, elapsed)
	_show_feedback(result, selected_index, correct_index)

	_feedback_finished_round = result.get("finished", false)
	_in_feedback = true
	_feedback_until = Time.get_ticks_msec() / 1000.0 + FEEDBACK_HOLD


func _end_feedback() -> void:
	_in_feedback = false
	if _feedback_finished_round:
		_finish_quiz()
	else:
		_show_current_question()


func _show_feedback(result: Dictionary, selected_index: int, correct_index: int) -> void:
	if result.get("is_timeout", false):
		feedback_label.text = tr("UI_TIME_UP")
		feedback_label.modulate = UiTokens.FEEDBACK_TIMEOUT
	elif result.get("is_correct", false):
		feedback_label.text = "%s  +%d" % [tr("UI_CORRECT"), result.get("points", 0)]
		feedback_label.modulate = UiTokens.FEEDBACK_CORRECT
	else:
		feedback_label.text = tr("UI_WRONG")
		feedback_label.modulate = UiTokens.FEEDBACK_WRONG
	_punch(feedback_label, 1.25)

	_animate_score(GameManager.score)
	_update_combo_badge(GameManager.combo, result.get("is_correct", false))

	# Estompe les réponses hors résultat pour focaliser l'attention.
	for index in range(answer_buttons.size()):
		if index != correct_index and index != selected_index:
			answer_buttons[index].modulate = Color(1, 1, 1, 0.45)

	if correct_index >= 0 and correct_index < answer_buttons.size():
		var good: Button = answer_buttons[correct_index]
		good.add_theme_stylebox_override("normal", UiStyle.answer_tile_state(UiTokens.FEEDBACK_CORRECT))
		good.add_theme_stylebox_override("disabled", UiStyle.answer_tile_state(UiTokens.FEEDBACK_CORRECT))
		_punch(good, 1.08)

	if (
		selected_index >= 0
		and selected_index < answer_buttons.size()
		and selected_index != correct_index
	):
		var bad: Button = answer_buttons[selected_index]
		bad.add_theme_stylebox_override("normal", UiStyle.answer_tile_state(UiTokens.FEEDBACK_WRONG))
		bad.add_theme_stylebox_override("disabled", UiStyle.answer_tile_state(UiTokens.FEEDBACK_WRONG))
		_shake(bad)


func _animate_score(target: int) -> void:
	if _score_tween != null and _score_tween.is_valid():
		_score_tween.kill()
	_score_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_score_tween.tween_method(_set_score_display, float(_displayed_score), float(target), 0.5)
	_displayed_score = target
	_punch(score_label, 1.18)


func _set_score_display(value: float) -> void:
	score_label.text = str(int(round(value)))


func _punch(node: Control, amount: float) -> void:
	node.pivot_offset = node.size * 0.5
	node.scale = Vector2.ONE * amount
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ONE, 0.28)


func _shake(node: Control) -> void:
	node.pivot_offset = node.size * 0.5
	var tween := create_tween()
	for angle in [0.06, -0.05, 0.035, -0.02, 0.0]:
		tween.tween_property(node, "rotation", angle, 0.05)


func _finish_quiz() -> void:
	_set_timer_pulse(false)
	GameManager.finish_round()
	get_tree().change_scene_to_file(ScenePaths.RESULTS)
