extends RefCounted

const UiTokens = preload("res://scripts/config/ui_tokens.gd")

const SCALE := UiTokens.BUTTON_PRESS_SCALE


static func wire(button: Button, host: Node) -> void:
	if button == null or host == null:
		return
	button.resized.connect(func() -> void:
		button.pivot_offset = button.size * 0.5
	)
	button.button_down.connect(func() -> void:
		button.pivot_offset = button.size * 0.5
		var tween: Tween = host.create_tween()
		tween.tween_property(button, "scale", Vector2.ONE * SCALE, 0.06)
	)
	button.button_up.connect(func() -> void:
		var tween: Tween = host.create_tween()
		tween.tween_property(button, "scale", Vector2.ONE, 0.08)
	)
