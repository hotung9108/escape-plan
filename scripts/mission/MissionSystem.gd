extends Node

@export var rescuse_point: Area2D
@export var timer: Timer

@export var missionObjects: Array[mission_object] = []
@export var rescusePosition: Vector2
@export var maxPickUpPrisonnerNumber: int = 1
@export var time_left = 300

var keyObject = preload("res://scenes/mission/key_object.tscn")
var cageObject = preload("res://scenes/mission/cage_object.tscn")
var prisonnerObject = preload("res://scenes/mission/prisonner.tscn")
var rescusePointObject = preload("res://scenes/mission/rescuse_point.tscn")
signal key_picked(color: Color)
signal mission_init(total_missions_number: int)
signal rescuse(number: int)
signal time_change(text: String)
signal time_up()

var missionSpawnNodes: Array[Node2D] = []
var pickUpKeys: Array[int] = []
var pickUpPrisonners: Array[Node2D] = []
var rescusePrisonnerNumber: int = 0
var available_spawn_nodes: Array[Node2D] = []

func _ready():
	for child in get_children():
		if child is Node2D:
			missionSpawnNodes.append(child)
	
	timer.timeout.connect(_on_timer_timeout)
	
	_setup()

func _setup():
	mission_init.emit(missionObjects.size())
	
	if rescuse_point == null:
		rescuse_point = rescusePointObject.instantiate()
		rescuse_point.position = rescusePosition
		add_child(rescuse_point)
	rescuse_point.body_entered.connect(on_player_enter_spawn)
	
	available_spawn_nodes = missionSpawnNodes.duplicate()
	
	for i in range(missionObjects.size()):
		var key_spawn_node = get_and_remove_random_spawn_node()
		if (key_spawn_node != null):
			var newKeyObject = keyObject.instantiate()
			newKeyObject.position = Vector2.ZERO
			key_spawn_node.add_child(newKeyObject)
			
			newKeyObject.get_node_or_null("KeyData").keyType = i
			newKeyObject.modulate = missionObjects[i].color
			newKeyObject.get_node("TriggerArea").body_entered.connect(func(body): on_player_enter_key(newKeyObject, body))
		
		var cage_spawn_node = get_and_remove_random_spawn_node()
		if (cage_spawn_node != null):
			var newCageObject = cageObject.instantiate()
			newCageObject.position = Vector2.ZERO
			cage_spawn_node.add_child(newCageObject)
			
			newCageObject.set_cage(missionObjects[i].color, i)
			newCageObject.get_node("TriggerArea").body_entered.connect(func(body): on_player_enter_cage(newCageObject, body))

func _on_timer_timeout():
	time_left -= 1
	time_change.emit(format_time(time_left))
	
	if time_left <= 0:
		timer.stop()
		print("Time up")
		time_up.emit()

func format_time(t: float) -> String:
	var minutes = int(t) / 60
	var seconds = int(t) % 60
	return "%02d:%02d" % [minutes, seconds]

# ✅ Get random spawn node and remove from pool
func get_and_remove_random_spawn_node() -> Node2D:
	if available_spawn_nodes.is_empty():
		# Pool exhausted, refill it
		available_spawn_nodes = missionSpawnNodes.duplicate()
	
	if available_spawn_nodes.is_empty():
		push_error("No spawn nodes available!")
		return null
	
	var random_index = randi() % available_spawn_nodes.size()
	var node = available_spawn_nodes[random_index]
	available_spawn_nodes.remove_at(random_index)
	
	return node

func on_player_enter_key(keyObject, body):
	if body.is_in_group("Player"):
		pickUpKeys.append(keyObject.get_node_or_null("KeyData").keyType)
		keyObject.visible = false
		keyObject.set_process(false)
		keyObject.get_node("TriggerArea").set_deferred("monitoring", false)
		print("Pick up keys: ", pickUpKeys)
		key_picked.emit(keyObject.modulate)

func on_player_enter_cage(cageObject, body):
	if body.is_in_group("Player"):
		if pickUpKeys.has(cageObject.cageType) and pickUpPrisonners.size() <= maxPickUpPrisonnerNumber - 1:
			var newPrisonner = prisonnerObject.instantiate()
			pickUpPrisonners.append(newPrisonner)
			await cageObject.open()
			if (missionObjects[cageObject.cageType].prisonnerSpriteFrames != null): 
				var sprite: AnimatedSprite2D = newPrisonner.get_node("AnimatedSprite2D")
				sprite.sprite_frames = missionObjects[cageObject.cageType].prisonnerSpriteFrames
			else:
				newPrisonner.setup(missionObjects[cageObject.cageType].color)
			newPrisonner.position = cageObject.global_position
			add_child(newPrisonner)
		else:
			cageObject.interact()

func on_player_enter_spawn(body):
	if body.is_in_group("Prisonner"):
		for i in range(pickUpPrisonners.size() - 1, -1, -1):
			#if pickUpPrisonners[i].state == "idle":
				rescusePrisonnerNumber += 1
				
				var prisoner = pickUpPrisonners[i]
				pickUpPrisonners.remove_at(i)
				
				prisoner.queue_free()
				
				print("Rescuse ", rescusePrisonnerNumber, " prisonner", "" if rescusePrisonnerNumber == 1 else "s")
				
				rescuse.emit(rescusePrisonnerNumber)

		if rescusePrisonnerNumber >= missionObjects.size():
			print("Mission completed")
