extends Area2D

var house

func _ready():
	house = get_parent()

func enter_house():
	print("Player enter house")
	GameManager.enter_house(house)
	house.get_node("Exterior").hide()
	#house.get_node("Interior").show()
func exit_house():
	print("Player exit house")
	
	GameManager.exit_house()
	house.get_node("Exterior").show()
	#house.get_node("Interior").hide()


func _on_body_entered(body: Node2D) -> void:
	
	if !body.is_in_group("player"):
		return

	if GameManager.player_inside_house:
		exit_house()
	else:
		enter_house()
