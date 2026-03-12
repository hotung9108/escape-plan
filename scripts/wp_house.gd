extends Node2D

@export var connections : Array[NodePath]

var neighbors = []

func _ready():
	for p in connections:
		var node = get_node(p)
		neighbors.append(node)
	#draw_connections()

func draw_connections():
	for n in neighbors:
		var line = Line2D.new()
		line.width = 2
		line.add_point(Vector2.ZERO)
		line.add_point(to_local(n.global_position))
		add_child(line)
