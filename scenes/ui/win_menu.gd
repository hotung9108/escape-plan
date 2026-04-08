extends Control

@onready var next_level_btn = $Panel/CenterContainer/VBoxContainer/HBoxContainer/Button
@onready var menu_btn = $Panel/CenterContainer/VBoxContainer/HBoxContainer/Button2
@onready var panel = $Panel

func _ready() -> void:
	UIThemeManager.apply_theme(self)
	panel.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.5)

	next_level_btn.pressed.connect(_on_next_level_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)
	
	_setup_button_hover(next_level_btn)
	_setup_button_hover(menu_btn)

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

func _on_next_level_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scenes/maps/map_01.tscn")

func _on_menu_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
