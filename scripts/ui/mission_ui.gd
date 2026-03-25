extends Control
class_name MissionUI

var key_object = preload("res://scenes/ui/mission/key_icon.tscn")

func add_key(color: Color):
	var new_key_icon = key_object.instantiate()
	new_key_icon.set_color(color)
	get_node("Panel/HBoxContainer").add_child(new_key_icon)

func set_mission(total_prisonners_number: int):
	get_node("Panel/HBoxContainer2/Label4").text = str(total_prisonners_number)

func set_rescuse(recuse_number: int):
	get_node("Panel/HBoxContainer2/Label2").text = str(recuse_number)


func set_time_left(text: String):
	get_node("Panel/HBoxContainer3/Label2").text = text
