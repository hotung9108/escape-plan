extends Node2D
var waypoints = []
var graph = {}
var room_manager
var MAX_DISTANCE = 200

func _ready() -> void:
	pass
func scan_waypoints():
	var wp_nodes = get_tree().get_nodes_in_group("waypoints")
	waypoints = wp_nodes

func build_graph():
	for wp in waypoints:
		graph[wp] = []
		for other in waypoints:
			if wp == other:
				continue
			if can_connect(wp, other):
				graph[wp].append(other)

func can_connect(a, b):
	if a.global_position.distance_to(b.global_position) > MAX_DISTANCE:
		return false
	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		a.global_position,
		b.global_position
	)
	var result = space.intersect_ray(query)
	return result.is_empty()
