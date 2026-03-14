extends Node

var game_over := false
var win := false


var player_inside_house: bool = false
var current_house: Node = null

func enter_house(house: Node):
	player_inside_house = true
	current_house = house

func exit_house():
	player_inside_house = false
	current_house = null

func trigger_game_over():
	game_over = true
	get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")

func trigger_win():
	win = true
	get_tree().change_scene_to_file("res://scenes/ui/WinScreen.tscn")
