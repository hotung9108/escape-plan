extends Control

@onready var back_btn = $Panel/VBoxContainer/Back
@onready var main_container = $Panel/VBoxContainer
@onready var panel = $Panel
@onready var volume_slider = $Panel/VBoxContainer/HSlider
@onready var fullscreen_checkbox = $Panel/VBoxContainer/CheckBox
static var volume_value: int = 100

func _ready() -> void:
	UIThemeManager.apply_theme(self )
	# Entrance animation
	panel.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.5)

	back_btn.pressed.connect(_on_back_pressed)
	volume_slider.value_changed.connect(on_volume_change)
	fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
	
	_setup_button_hover(back_btn)
	
	# Initialize slider value from static persistent value
	volume_slider.value = volume_value
	on_volume_change(volume_value)

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
	
	if get_tree().current_scene and get_tree().current_scene.scene_file_path == "res://scenes/ui/setting_menu.tscn":
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	else:
		if GameManager.pause_layer:
			for child in GameManager.pause_layer.get_children():
				if child != self:
					child.show()
					var tw = create_tween()
					tw.tween_property(child, "modulate", Color.WHITE, 0.2)
		queue_free()


func on_volume_change(value: float) -> void:
	volume_value = int(value)
	# Convert 0-100 range to linear 0.0-1.0 then to dB
	# linear_to_db(0.0) is -80.0 in Godot (or -inf)
	var volume_db = linear_to_db(value / 100.0)
	
	var sound_nodes = get_tree().get_nodes_in_group("Sound")
	for node in sound_nodes:
		if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D:
			node.volume_db = volume_db

func _on_fullscreen_toggled(button_pressed: bool) -> void:
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
