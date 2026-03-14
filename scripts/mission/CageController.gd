extends Node

var cageType: int

func set_cage(color, type):
	get_node("Lock").modulate = color
	cageType = type
	
	
func interact():
	get_node("CageAnimator").play("interact")
	await get_node("CageAnimator").animation_finished
	get_node("CageAnimator").play("idle")
	
func open():
	get_node("CageAnimator").play("break")
	get_node("Lock").visible = false
	await get_node("CageAnimator").animation_finished
	get_node("CollisionShape2D").disabled = true
	get_node("TriggerArea").set_deferred("monitoring", false)
