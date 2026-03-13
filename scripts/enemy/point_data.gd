extends Node2D

@export var relativeNodes: Array[Node2D] = []

var vertexWeight: int

func _ready():
	get_parent().nodes.append(self)
	print(get_parent().nodes)

func set_vertex_weight(value: int, parent: Node2D):
	vertexWeight = value
	modulate = Color(1.0, 1.0, 1.0, 1.0 - (0.2 * value))
	
	get_parent().playerRelatedPoints.append(self)
	
	if value == PathSystem.maxChildGeneration: return
	
	for r in relativeNodes:
		if r == parent and parent != null:
			continue
		r.set_vertex_weight(value + 1, self)

func reset_node():
	vertexWeight = PathSystem.maxChildGeneration + 1
	modulate = Color.CRIMSON
