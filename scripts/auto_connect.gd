extends Node2D


@export var max_connect_distance: float = 400.0
@export var enable_auto_connect := true

var point: Node2D
var path_system
var all_points: Array
func _ready():
	if not enable_auto_connect:
		return

	point = get_parent()
	path_system = point.get_parent()
	await get_tree().process_frame 
	
	all_points = get_tree().get_nodes_in_group("Points")
	#await get_tree().create_timer(0.1).timeout
	auto_connect()
func is_blocked(target: Node2D) -> bool:
	var ray = point.get_node("RayCast2D")
	ray.target_position = ray.to_local(target.global_position)
	ray.force_raycast_update()
	return ray.is_colliding()
func auto_connect():
	point.clear_connections()
	for p in all_points:
		if p == point:
			continue
		var dist = point.global_position.distance_to(p.global_position)
		if dist > max_connect_distance:
			continue
		if is_blocked(p):
			continue

		point.add_connection(p)

	point.queue_redraw()
