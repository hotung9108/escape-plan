extends Control

var heart_icon = preload("res://scenes/ui/heart.tscn")

func add_heart(number: int):
	for i in range(number):
		var new_h = heart_icon.instantiate()
		get_node("VBoxContainer/HealthBar").add_child(new_h)
	
func remove_children_to_count(target_count: int):
	var object = get_node("VBoxContainer/HealthBar")
	while object.get_child_count() > target_count:
		var last_child = object.get_child(object.get_child_count() - 1)
		last_child.queue_free()

func update_stamina(current: float, max_val: float):
	var stamina_bar = get_node("VBoxContainer/StaminaBar")
	stamina_bar.max_value = max_val
	stamina_bar.value = current
