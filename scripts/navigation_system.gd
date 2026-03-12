extends Node2D
var waypoints = []
var graph = {}

var room_manager


func _ready():
	room_manager = get_parent().get_node("RoomManager")
	scan_waypoints()
	build_graph()
func scan_waypoints():
	var wp_container = get_parent().get_node("House/WayPoints_House")
	waypoints = wp_container.get_children()
func build_graph():
	for wp in waypoints:
		graph[wp] = wp.neighbors
func get_position_of(entity):
	return entity.global_position
#func get_my_position(entity):
	#return entity.global_position
	
func get_nearest_waypoint(target_position):
	var best_wp = null
	var best_dist = INF
	for wp in waypoints:
		var d = target_position.distance_to(wp.global_position)
		if d < best_dist:
			best_dist = d
			best_wp = wp
	return best_wp
	
func get_neighbors_of(entity):
	var wp = get_nearest_waypoint(entity.global_position)
	return graph[wp]
	
func reconstruct_path(came_from, current):
	var path = [current]
	while came_from.has(current):
		current = came_from[current]
		path.push_front(current)
	return path
func find_path(start, goal):
	var open = [start]
	var came_from = {}
	while open.size() > 0:
		var current = open.pop_front()
		if current == goal:

			return reconstruct_path(came_from, current)

		for neighbor in graph[current]:

			if not came_from.has(neighbor):

				came_from[neighbor] = current

				open.append(neighbor)
	return []
