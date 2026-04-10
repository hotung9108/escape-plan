extends Control

@onready var start_btn = $CenterContainer/VBoxContainer/Start
@onready var inst_btn = $CenterContainer/VBoxContainer/Instructions
@onready var settings_btn = $CenterContainer/VBoxContainer/Settings
@onready var quit_btn = $CenterContainer/VBoxContainer/Quit
@onready var main_container = $CenterContainer

func _ready() -> void:
	UIThemeManager.apply_theme(self)
	var bg = ColorRect.new()
	bg.color = Color(0.02, 0.0, 0.0, 1.0)
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	move_child(bg, 0)
	
	start_btn.pressed.connect(_on_start_pressed)
	inst_btn.pressed.connect(_on_instructions_pressed)
	settings_btn.pressed.connect(_on_options_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	_setup_button_hover(start_btn)
	_setup_button_hover(inst_btn)
	_setup_button_hover(settings_btn)
	_setup_button_hover(quit_btn)

	main_container.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(main_container, "modulate", Color(1, 1, 1, 1), 1.5).set_trans(Tween.TRANS_SINE)

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

func _on_start_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(main_container, "modulate", Color(0, 0, 0, 0), 1.0)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/maps/map_01.tscn")

func _on_instructions_pressed() -> void:
	var instruction_panel = load("res://scenes/ui/instruction_menu.tscn").instantiate()
	add_child(instruction_panel)

func _on_options_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(main_container, "modulate", Color(0, 0, 0, 0), 0.3)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/ui/setting_menu.tscn")

func _on_quit_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(main_container, "modulate", Color(0, 0, 0, 0), 0.5)
	await tween.finished
	get_tree().quit()
