extends Node

const QuestionLoaderScript = preload("res://scripts/quiz/question_loader.gd")
const ScoringSystemScript = preload("res://scripts/quiz/scoring_system.gd")

const QUESTIONS_PER_ROUND: int = 7
const QUESTION_TIME_SECONDS: float = 10.0

var category_id: String = ""
var questions: Array[Dictionary] = []
var current_index: int = 0
var score: int = 0
var correct_count: int = 0
var combo: int = 0
var max_combo: int = 0
var answer_times: Array[float] = []
var last_summary: Dictionary = {}
var shell_tab_index: int = 0


func start_round(selected_category_id: String) -> void:
	category_id = selected_category_id
	questions = QuestionLoaderScript.load_questions_for_category(
		category_id,
		LocaleManager.get_content_locale(),
		QUESTIONS_PER_ROUND
	)
	current_index = 0
	score = 0
	correct_count = 0
	combo = 0
	max_combo = 0
	answer_times.clear()


func has_questions() -> bool:
	return not questions.is_empty()


func get_current_question() -> Dictionary:
	if current_index >= questions.size():
		return {}
	return questions[current_index]


func get_progress_label() -> String:
	return "%d / %d" % [min(current_index + 1, questions.size()), questions.size()]


func submit_answer(selected_index: int, elapsed_seconds: float) -> Dictionary:
	var question: Dictionary = get_current_question()
	if question.is_empty():
		return {"finished": true}

	var is_timeout: bool = selected_index < 0
	var is_correct: bool = not is_timeout and selected_index == int(question.get("correct_index", -1))
	var points: int = 0

	if is_correct:
		correct_count += 1
		combo += 1
		max_combo = max(max_combo, combo)
		points = ScoringSystemScript.calculate_points(elapsed_seconds, QUESTION_TIME_SECONDS, combo)
		score += points
	else:
		combo = 0

	answer_times.append(elapsed_seconds)
	current_index += 1

	return {
		"finished": current_index >= questions.size(),
		"is_correct": is_correct,
		"is_timeout": is_timeout,
		"points": points,
		"combo": combo,
	}


func finish_round() -> Dictionary:
	var average_time: float = 0.0
	if not answer_times.is_empty():
		var total_time: float = 0.0
		for value in answer_times:
			total_time += value
		average_time = total_time / answer_times.size()

	var summary := {
		"category_id": category_id,
		"score": score,
		"correct_count": correct_count,
		"total_count": questions.size(),
		"max_combo": max_combo,
		"average_time": average_time,
	}

	SaveManager.record_match_result(
		category_id,
		score,
		correct_count,
		questions.size()
	)
	last_summary = summary
	return summary
