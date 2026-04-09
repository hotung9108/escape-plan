extends Node

func go_to_lose_menu():
	get_tree().change_scene_to_file("res://scenes/ui/lose_menu.tscn")

func go_to_win_menu():
	get_tree().change_scene_to_file("res://scenes/ui/win_menu.tscn")
