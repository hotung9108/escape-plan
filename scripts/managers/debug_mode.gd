extends Node

@export var is_enabled: bool = false

func _ready():
	toggle_debug_mode()

func _input(event: InputEvent):
	if event.is_action_pressed("debug_mode"):
		print("Toggle debug mode")
		toggle_debug_mode()

func toggle_debug_mode():
	is_enabled = !is_enabled
	
	var player = get_tree().get_first_node_in_group("Player")
	
	player.toggle_debug_mode(is_enabled)
	
	var points = get_tree().get_nodes_in_group("Points")
	for p in points:
		# Directly toggle the debug_draw property on navigation points
		if "debug_draw" in p:
			p.debug_draw = is_enabled
			if p.has_method("queue_redraw"):
				p.queue_redraw()
