extends Control
class_name ArcMeter

@export var value: float = 0.0
@export var accent := Color(0.42, 0.361, 1.0, 1)
@export var track := Color(1, 1, 1, 0.1)
@export var line_width: float = 11.0


func set_ratio(ratio: float, color: Color) -> void:
	value = clampf(ratio, 0.0, 1.0)
	accent = color
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.38
	var start := -PI * 0.75
	var span := PI * 1.5
	draw_arc(center, radius, start, start + span, 48, track, line_width, true)
	if value > 0.001:
		draw_arc(center, radius, start, start + span * value, 48, accent, line_width, true)
