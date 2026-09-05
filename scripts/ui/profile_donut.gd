extends Control
class_name ProfileDonut

## Multi-segment donut for profile win distribution.

var segments: Array = [] ## [{ratio: float, color: Color}]
var center_label: String = ""
var track := Color(1, 1, 1, 0.08)
var line_width: float = 14.0


func set_segments(values: Array, label: String) -> void:
	segments = values
	center_label = label
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.38
	draw_arc(center, radius, 0.0, TAU, 64, track, line_width, true)
	var angle := -PI * 0.5
	for segment in segments:
		if typeof(segment) != TYPE_DICTIONARY:
			continue
		var ratio := clampf(float(segment.get("ratio", 0.0)), 0.0, 1.0)
		if ratio <= 0.001:
			continue
		var span := TAU * ratio
		var color: Color = segment.get("color", Color.WHITE)
		draw_arc(center, radius, angle, angle + span, 48, color, line_width, true)
		angle += span

	if not center_label.is_empty():
		var font := ThemeDB.fallback_font
		var font_size := 12
		var text_size := font.get_string_size(center_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		draw_string(
			font,
			center - text_size * 0.5 + Vector2(0, font_size * 0.35),
			center_label,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size,
			Color(1, 1, 1, 0.92)
		)
