extends Node

var game_over := false
var win := false


var player_inside_house: bool = false
var current_house: Node = null

var pause_layer: CanvasLayer = null
var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")
var pause_menu_instance: Control = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	if get_tree().current_scene.name in ["MainMenu", "WinMenu", "LoseMenu", "SettingMenu", "GameOver", "WinScreen", "pause_menu"]:
		return
	
	if get_tree().paused:
		unpause_game()
	else:
		pause_game()

func pause_game():
	# If we are already fading out, clear it
	if pause_layer:
		pause_layer.queue_free()
		pause_layer = null

	get_tree().paused = true
	
	pause_layer = CanvasLayer.new()
	pause_layer.layer = 100
	get_tree().root.add_child(pause_layer)
	
	pause_menu_instance = pause_menu_scene.instantiate()
	pause_menu_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_layer.add_child(pause_menu_instance)
	
	# Force anchor to full rect and set pivot for zoom
	pause_menu_instance.anchor_right = 1.0
	pause_menu_instance.anchor_bottom = 1.0
	pause_menu_instance.pivot_offset = pause_menu_instance.size / 2.0
	
	pause_menu_instance.scale = Vector2(0.8, 0.8)
	pause_menu_instance.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(pause_menu_instance, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(pause_menu_instance, "modulate", Color.WHITE, 0.2)

func unpause_game(immediate: bool = false):
	get_tree().paused = false
	
	if immediate:
		if pause_layer:
			pause_layer.queue_free()
			pause_layer = null
			pause_menu_instance = null
		return
		
	if pause_menu_instance:
		var tween = create_tween()
		tween.tween_property(pause_menu_instance, "scale", Vector2(0.8, 0.8), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(pause_menu_instance, "modulate", Color(1, 1, 1, 0), 0.15)
		await tween.finished
		
	if pause_layer:
		pause_layer.queue_free()
		pause_layer = null
		pause_menu_instance = null

func enter_house(house: Node):
	player_inside_house = true
	current_house = house

func exit_house():
	player_inside_house = false
	current_house = null

func trigger_game_over():
	game_over = true
	get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")

func trigger_win():
	win = true
	get_tree().change_scene_to_file("res://scenes/ui/WinScreen.tscn")
