extends Control

@onready var back_btn = $Panel/VBoxContainer/Back
@onready var main_container = $Panel/VBoxContainer
@onready var panel = $Panel

func _ready() -> void:
	# Entrance animation
	panel.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.5)

	back_btn.pressed.connect(_on_back_pressed)
	
	_setup_button_hover(back_btn)

func _setup_button_hover(btn: Button) -> void:
	btn.mouse_entered.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "modulate", Color(0.8, 0.1, 0.1, 1.0), 0.2)
		tween.parallel().tween_property(btn, "scale", Vector2(1.05, 1.05), 0.2)
		btn.pivot_offset = btn.size / 2.0
	)
	btn.mouse_exited.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "modulate", Color.WHITE, 0.3)
		tween.parallel().tween_property(btn, "scale", Vector2.ONE, 0.3)
	)

func _on_back_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(panel, "modulate", Color(0, 0, 0, 0), 0.3)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
