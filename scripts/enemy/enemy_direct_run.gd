extends Node

var player: Node2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	

func run() -> Vector2:
	return get_parent().position.direction_to(player.position)
