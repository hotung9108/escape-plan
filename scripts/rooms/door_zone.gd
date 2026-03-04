extends Area2D

@export var roof_layer: Node

func _on_body_entered(body):
	if body.is_in_group("player"):
		roof_layer.visible = false

func _on_body_exited(body):
	if body.is_in_group("player"):
		roof_layer.visible = true
