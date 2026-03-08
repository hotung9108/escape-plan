extends Area2D

@export var roof_layer: Node

func _on_body_entered(body):
	if body.is_in_group("player"):
		roof_layer.visible = false

func _on_body_exited(body):
	if body.is_in_group("player"):
		roof_layer.visible = true

#extends Area2D
#
#@export var interior_root: Node2D
#@export var exterior_root: Node2D
#
#func _on_body_entered(body):
	#if body.is_in_group("player"):
		#interior_root.visible = true
		#exterior_root.visible = false
#
#func _on_body_exited(body):
	#if body.is_in_group("player"):
		#interior_root.visible = false
		#exterior_root.visible = true
