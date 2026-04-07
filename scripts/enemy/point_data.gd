extends Node2D

var wallRaycast: RayCast2D

@export var relativeNodes: Array[Node2D] = []

var relativeNodesDistance: Array[float] = []
var vertexWeight: int
var parentPathSystem: PathSystem
@export var debug_draw := true 
func _draw():
	if not debug_draw:
		return

	draw_circle(Vector2.ZERO, 5, Color.YELLOW)

	for i in range(relativeNodes.size()):
		if i >= relativeNodesDistance.size():
			continue

		var r = relativeNodes[i]
		if not is_instance_valid(r):
			continue

		if get_instance_id() > r.get_instance_id():
			continue

		var local_pos = to_local(r.global_position)

		var dist = relativeNodesDistance[i]
		var color = Color.GREEN.lerp(Color.RED, dist / 300.0)

		draw_line(Vector2.ZERO, local_pos, color, 2.0)
		
func _ready():
	clear_connections()
	
	wallRaycast = get_node("RayCast2D")
	
	reset_node()
	parentPathSystem = get_parent()
	
	parentPathSystem.nodes.append(self)
	add_to_group("Points")
	#for r in relativeNodes:
		#relativeNodesDistance.push_back(position.distance_squared_to(r.position))
func clear_connections():
	relativeNodes.clear()
	relativeNodesDistance.clear()
	
func add_connection(node: Node2D):
	if relativeNodes.has(node):
		return
	var dist = global_position.distance_to(node.global_position)
	relativeNodes.append(node)
	relativeNodesDistance.append(dist)
func set_vertex_weight(value: int, parent: Node2D):
	vertexWeight = value
	modulate = Color(1.0, 1.0, 1.0, 1.0 - (0.2 * value))
	
	get_parent().playerRelatedPoints.append(self)
	
	#if value == PathSystem.maxChildGeneration: return
	#
	#for r in relativeNodes:
		#if r == parent and parent != null:
			#continue
		#r.set_vertex_weight(value + 1, self)

func reset_node():
	vertexWeight = PathSystem.maxChildGeneration + 1
	modulate = Color.CRIMSON

func check_wall(position: Vector2) -> bool:
	
	wallRaycast.enabled = true
	
	wallRaycast.target_position = to_local(position)
	wallRaycast.force_raycast_update()
	
	if wallRaycast.is_colliding():
		wallRaycast.enabled = false
		return true
	
	wallRaycast.enabled = false
	return false
