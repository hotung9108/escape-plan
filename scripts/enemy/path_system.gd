extends Node
class_name PathSystem

#Config
static var maxChildGeneration: int = 6
static var maxDistance: float = 15

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
	canCalculate = true
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
	
	mapData.playerNeareastPoint.set_vertex_weight(0, null)

func reset_player_related_points():
	for p in playerRelatedPoints:
		p.reset_node()
	
	playerRelatedPoints.clear()

func activate():
	canCalculate = true

func deactivate():
	canCalculate = false
	reset_player_related_points()
