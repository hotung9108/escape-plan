extends Node
class_name PathSystem

#Config
static var maxChildGeneration: int = 6
static var maxDistance: float = 100

# Dependencies
@export var player: Node2D
@export var mapData: Node

# Attributes
@export var nodes: Array[Node2D] = []

# Runtime
var playerRelatedPoints: Array[Node2D] = []
var playerNeareastPoint: Node2D
var canCalculate: bool = false

func _ready() -> void:
	reset_player_related_points()
	player = get_tree().get_first_node_in_group("Player")
	mapData = get_tree().get_first_node_in_group("Map")
	calculate_player_relative_points_vertex_weight()
	maxDistance = maxDistance * maxDistance

func _process(delta: float):
	calculate_player_relative_points_vertex_weight()

func find_object_nearest_node(object: Node2D) -> Node2D:
	if nodes.is_empty() or not object:
		return null
	
	var nearest_node: Node2D = nodes[0]
	var min_distance_squared := object.position.distance_squared_to(nearest_node.position)
	for i in range(1, nodes.size()):
		var distance_squared := object.position.distance_squared_to(nodes[i].position)
		if distance_squared < min_distance_squared:
			min_distance_squared = distance_squared
			nearest_node = nodes[i]
	return nearest_node 

func calculate_player_relative_points_vertex_weight():
	if !canCalculate: return
	
	var newNeareastPoint = find_object_nearest_node(player)
	
	if newNeareastPoint == null: return
	
	if newNeareastPoint == mapData.playerNeareastPoint: return
	
	mapData.playerNeareastPoint = newNeareastPoint
	await reset_player_related_points()
	
	set_vertex_weights_iterative(mapData.playerNeareastPoint)

func reset_player_related_points():
	for p in playerRelatedPoints:
		p.reset_node()
	
	playerRelatedPoints.clear()

func activate(body: Node2D):
	if body.is_in_group("Player"):
		canCalculate = true
	
	if body.is_in_group("Enemy"):
		body.enter_room(self)

func deactivate(body: Node2D):
	if body.is_in_group("Player"):
		canCalculate = false
		reset_player_related_points()
	
	if body.is_in_group("Enemy"):
		body.enter_room(self)

func set_vertex_weights_iterative(start_node: Node2D):
	if start_node == null:
		return
	
	var queue = []
	var visited = {}
	
	# Start with weight 0
	queue.append({"node": start_node, "weight": 0, "parent": null})
	
	while not queue.is_empty():
		var current = queue.pop_front()
		var node: Node2D = current.node
		var weight: int = current.weight
		var parent: Node2D = current.parent
		
		# Skip if already visited with better or equal weight
		if node in visited and visited[node] <= weight:
			continue
		
		visited[node] = weight
		
		# ✅ Set vertex weight
		node.vertexWeight = weight
		node.modulate = Color(1.0, 1.0, 1.0, 1.0 - (0.2 * weight))
		playerRelatedPoints.append(node)
		
		# ✅ Stop if max generation reached
		if weight >= maxChildGeneration:
			continue
		
		# ✅ Add neighbors to queue
		for neighbor in node.relativeNodes:
			if neighbor != parent:  # Don't go back
				queue.append({
					"node": neighbor,
					"weight": weight + 1,
					"parent": node
				})
