extends Node2D

#var rooms = {}
#
#var player_current_room = null
#var player_last_seen_room = null
#
#func _ready():
	#var rooms_node = get_tree().current_scene.get_node("Rooms")
	#for r in rooms_node.get_children():
		#rooms[r.room_id] = r
		
var rooms = []
var player_current_room = null
func _ready():
	scan_rooms()
func scan_rooms():
	rooms = get_tree().get_nodes_in_group("room_group")
