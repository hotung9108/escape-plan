extends Node

var playerNeareastPoint: Node2D
var currentPathSystem: Node2D
@onready var all_path_systems: Array = get_tree().get_nodes_in_group("PathSystem")

func activate_new_path_system(newPs: Node2D):
	if currentPathSystem != null && currentPathSystem != newPs:
		currentPathSystem.canCalculate = false
		currentPathSystem.reset_player_related_points()
	
	newPs.canCalculate = true
	
	currentPathSystem = newPs
