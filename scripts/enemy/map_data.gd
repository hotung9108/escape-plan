extends Node

var playerNeareastPoint: Node2D
var currentPathSystem: Node2D

func activate_new_path_system(newPs: Node2D):
	if currentPathSystem != null && currentPathSystem != newPs:
		currentPathSystem.canCalculate = false
		currentPathSystem.reset_player_related_points()
	
	newPs.canCalculate = true
	
	currentPathSystem = newPs
