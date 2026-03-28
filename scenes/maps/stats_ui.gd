extends Control

var heart_icon = preload("res://scenes/ui/heart.tscn")

func add_heart(number: int):
	for i in range(number):
		var new_h = heart_icon.instantiate()
		get_node("HealthBar").add_child(new_h)
	
func remove_children_to_count(target_count: int):
	var object = get_node("HealthBar")
	while object.get_child_count() > target_count:
		var last_child = object.get_child(object.get_child_count() - 1)
		last_child.queue_free()
