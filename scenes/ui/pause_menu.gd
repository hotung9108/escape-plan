extends Control

@onready var resume_btn = $Panel/CenterContainer/VBoxContainer/Button
@onready var settings_btn = $Panel/CenterContainer/VBoxContainer/Button2
@onready var menu_btn = $Panel/CenterContainer/VBoxContainer/Button3
@onready var panel = $Panel

func _ready() -> void:
	UIThemeManager.apply_theme(self)
	panel.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.3)

	resume_btn.pressed.connect(_on_resume_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)
	
	_setup_button_hover(resume_btn)
	_setup_button_hover(settings_btn)
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

func _on_resume_pressed() -> void:
	GameManager.unpause_game()

func _on_settings_pressed() -> void:
	# Hide the pause menu content
	self.hide()
	
	# Instantiate settings menu into the high-priority CanvasLayer
	var settings = load("res://scenes/ui/setting_menu.tscn").instantiate()
	settings.process_mode = Node.PROCESS_MODE_ALWAYS
	# Make sure it fills the screen
	settings.set_anchors_preset(PRESET_FULL_RECT)
	GameManager.pause_layer.add_child(settings)

func _on_menu_pressed() -> void:
	GameManager.unpause_game(true)
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
