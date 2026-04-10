extends Control

@onready var close_btn = $Panel/MarginContainer/VBoxContainer/TitleBox/CloseButton
@onready var panel = $Panel

func _ready() -> void:
	UIThemeManager.apply_theme(self)
	
	# Entrance animation
	panel.modulate = Color(1, 1, 1, 0)
	panel.scale = Vector2(0.9, 0.9)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.4)
	tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.4)
	
	close_btn.pressed.connect(_on_close_pressed)
	_setup_button_hover(close_btn)

func _setup_button_hover(btn: Button) -> void:
	btn.mouse_entered.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "modulate", Color(0.8, 0.1, 0.1, 1.0), 0.2)
		tween.parallel().tween_property(btn, "scale", Vector2(1.1, 1.1), 0.2)
		btn.pivot_offset = btn.size / 2.0
	)
	btn.mouse_exited.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "modulate", Color.WHITE, 0.2)
		tween.parallel().tween_property(btn, "scale", Vector2.ONE, 0.2)
	)

func _on_close_pressed() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 0), 0.3)
	tween.parallel().tween_property(panel, "scale", Vector2(0.9, 0.9), 0.3)
	await tween.finished
	queue_free()
