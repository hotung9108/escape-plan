extends Node

@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_count: int = 5

func _ready():
	# Use call_deferred to ensure all nodes in the tree have registered themselves 
	# to their respective groups and processed their own _ready logic.
	call_deferred("_spawn_enemies")

func _spawn_enemies():
	if enemy_scenes.is_empty():
		push_warning("EnemySpawner: No enemy scenes assigned in the inspector.")
		return
	
	var all_rooms = get_tree().get_nodes_in_group("PathSystem")
	if all_rooms.is_empty():
		push_warning("EnemySpawner: No rooms found in 'PathSystem' group. Spawning aborted.")
		return
	
	# Randomize the list of rooms to ensure random distribution
	var available_rooms = all_rooms.duplicate()
	available_rooms.shuffle()
	
	# Local constraint: each room can only have at most 1 enemy.
	# We cap the spawn count to the number of available rooms.
	if spawn_count > available_rooms.size():
		print("EnemySpawner: Requested spawn_count (%d) exceeds available rooms (%d). Capping to room count." % [spawn_count, available_rooms.size()])
	
	var final_spawn_count = min(spawn_count, available_rooms.size())

	for i in range(final_spawn_count):
		var room = available_rooms[i]
		
		# Ensure the room actually has valid points for spawning
		if room.nodes.is_empty():
			push_warning("EnemySpawner: Room '%s' has no valid nodes (points). Skipping room." % room.name)
			continue
		
		# Pick an enemy scene. 
		# If spawn_count > enemy_scenes.size(), we start duplicating (using modulo).
		var enemy_scene = enemy_scenes[i % enemy_scenes.size()]
		
		# Pick a random point within the current room
		var spawn_point = room.nodes.pick_random()
		
		# Instantiate and add to the scene
		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		
		# Position the enemy at the selected point
		enemy.global_position = spawn_point.global_position
		
		# Associate the enemy with the room it spawned in
		if enemy.has_method("enter_room"):
			enemy.enter_room(room)
		
		print("EnemySpawner: Spawned %s in room %s" % [enemy.name, room.name])
