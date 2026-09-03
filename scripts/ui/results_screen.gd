extends Control

const UiTokens = preload("res://scripts/config/ui_tokens.gd")
const UiStyle = preload("res://scripts/config/ui_style.gd")
const PressScaleUtil = preload("res://scripts/ui/press_scale.gd")
const ScenePaths = preload("res://scripts/config/scene_paths.gd")

@onready var score_caption_label: Label = %ScoreCaption
@onready var correct_caption_label: Label = %CorrectCaption
@onready var combo_caption_label: Label = %ComboCaption
@onready var average_caption_label: Label = %AverageCaption
@onready var title_label: Label = %TitleLabel
@onready var grade_label: Label = %GradeLabel
@onready var perfect_banner: Label = %PerfectBanner
@onready var score_value_label: Label = %ScoreValueLabel
@onready var correct_value_label: Label = %CorrectValueLabel
@onready var combo_value_label: Label = %ComboValueLabel
@onready var average_value_label: Label = %AverageValueLabel
@onready var play_again_button: Button = %PlayAgainButton
@onready var menu_button: Button = %MenuButton
@onready var stats_panel: PanelContainer = %StatsPanel

var summary: Dictionary = {}


func _ready() -> void:
	summary = GameManager.last_summary
	stats_panel.add_theme_stylebox_override("panel", UiStyle.card(UiTokens.ACCENT_QUIZ))
	title_label.add_theme_color_override("font_color", UiTokens.INK)
	combo_value_label.add_theme_color_override("font_color", UiTokens.ACCENT_QUIZ)
	average_value_label.add_theme_color_override("font_color", UiTokens.INK)
	_apply_translations()
	play_again_button.pressed.connect(_on_play_again_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	LocaleManager.locale_changed.connect(_on_locale_changed)
	PressScaleUtil.wire(play_again_button, self)
	PressScaleUtil.wire(menu_button, self)
	_play_intro()


func _apply_translations() -> void:
	title_label.text = tr("UI_RESULTS")
	perfect_banner.text = tr("UI_ACH_PERFECT")
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


func _grade() -> Dictionary:
	var total: int = int(summary.get("total_count", 0))
	var correct: int = int(summary.get("correct_count", 0))
	var ratio: float = 0.0 if total <= 0 else float(correct) / float(total)
	if correct == total and total > 0:
		return {"letter": "S", "color": Color(0.95, 0.75, 0.2, 1), "perfect": true}
	if ratio >= 0.85:
		return {"letter": "A", "color": UiTokens.FEEDBACK_CORRECT, "perfect": false}
	if ratio >= 0.7:
		return {"letter": "B", "color": UiTokens.ACCENT_QUIZ, "perfect": false}
	if ratio >= 0.5:
		return {"letter": "C", "color": Color(0.96, 0.6, 0.2, 1), "perfect": false}
	return {"letter": "D", "color": UiTokens.INK_MUTED, "perfect": false}


func _play_intro() -> void:
	await get_tree().process_frame
	var grade: Dictionary = _grade()
	grade_label.text = grade["letter"]
	grade_label.add_theme_color_override("font_color", grade["color"])

	grade_label.pivot_offset = grade_label.size * 0.5
	grade_label.scale = Vector2.ONE * 0.4
	grade_label.modulate.a = 0.0
	var g_tween := create_tween()
	g_tween.tween_interval(0.1)
	g_tween.set_parallel(true)
	g_tween.tween_property(grade_label, "modulate:a", 1.0, 0.2)
	g_tween.tween_property(grade_label, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	stats_panel.modulate.a = 0.0
	var s_tween := create_tween()
	s_tween.tween_interval(0.25)
	s_tween.tween_property(stats_panel, "modulate:a", 1.0, 0.3)

	_count_up(score_value_label, int(summary.get("score", 0)), "%d")
	_count_up_fraction(
		correct_value_label,
		int(summary.get("correct_count", 0)),
		int(summary.get("total_count", 0)),
	)

	if grade.get("perfect", false):
		perfect_banner.visible = true
		perfect_banner.modulate.a = 0.0
		var p_tween := create_tween()
		p_tween.tween_interval(0.45)
		p_tween.tween_property(perfect_banner, "modulate:a", 1.0, 0.25)
		_burst()


func _count_up(label: Label, target: int, fmt: String) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_method(
		func(v: float) -> void: label.text = fmt % int(round(v)),
		0.0,
		float(target),
		0.6,
	)


func _count_up_fraction(label: Label, target: int, total: int) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_method(
		func(v: float) -> void: label.text = "%d / %d" % [int(round(v)), total],
		0.0,
		float(target),
		0.6,
	)


func _burst() -> void:
	var origin := grade_label.global_position + grade_label.size * 0.5
	for i in range(14):
		var piece := ColorRect.new()
		piece.color = UiTokens.answer_slot_color(i % UiTokens.ANSWER_SLOTS.size())
		piece.size = Vector2(10, 10)
		piece.pivot_offset = Vector2(5, 5)
		piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
		piece.global_position = origin
		add_child(piece)
		var angle := TAU * float(i) / 14.0 + randf() * 0.3
		var dist := 90.0 + randf() * 70.0
		var dest := origin + Vector2(cos(angle), sin(angle)) * dist + Vector2(0, 40)
		var tween := create_tween().set_parallel(true)
		tween.tween_property(piece, "global_position", dest, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(piece, "rotation", randf_range(-3.0, 3.0), 0.7)
		tween.tween_property(piece, "modulate:a", 0.0, 0.7).set_delay(0.15)
		tween.chain().tween_callback(piece.queue_free)


func _on_play_again_pressed() -> void:
	GameManager.start_round(summary.get("category_id", ""))
	if GameManager.has_questions():
		get_tree().change_scene_to_file(ScenePaths.QUIZ_GAME)
	else:
		ScenePaths.go_to_shell(get_tree(), ScenePaths.Tab.QUIZ)


func _on_menu_pressed() -> void:
	ScenePaths.go_to_shell(get_tree(), ScenePaths.Tab.HOME)


func _on_locale_changed(_locale: String) -> void:
	_apply_translations()
