extends Node2D
var waypoints = []
var graph = {}
func _ready():
	var wp_node = get_tree().current_scene.get_node("WayPoints_House")
	for wp in wp_node.get_children():
		waypoints.append(wp)
