extends Node

var game_over := false
var win := false

func trigger_game_over():
	game_over = true
	get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")

func trigger_win():
	win = true
	get_tree().change_scene_to_file("res://scenes/ui/WinScreen.tscn")
