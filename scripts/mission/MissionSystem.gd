extends Node

# Dependencies
@export var player: Node2D

# Attributes 
@export var missionObjects: Array[mission_object] = []
@export var rescusePosition: Vector2

# Resources
var keyObject = preload("res://scenes/mission/key_object.tscn")
var cageObject = preload("res://scenes/mission/cage_object.tscn")
var prisonnerObject = preload("res://scenes/mission/prisonner.tscn")
var rescusePointObject = preload("res://scenes/mission/rescuse_point.tscn")

# Runtime vars
var pickUpKeys: Array[int] = []
var pickUpPrisonners: Array[Node2D] = []
var rescusePrisonnerNumber: int = 0

func _ready():
	var rescuse_point = rescusePointObject.instantiate()
	rescuse_point.position = rescusePosition
	rescuse_point.body_entered.connect(on_player_enter_spawn)
	add_child(rescuse_point)
	
	for i in range(missionObjects.size()):
		var newKeyObject = keyObject.instantiate()
		newKeyObject.position = Vector2(0, (i + 1) * 50)
		add_child(newKeyObject)
		
		newKeyObject.get_node_or_null("KeyData").keyType = i
		newKeyObject.modulate = missionObjects[i].color
		newKeyObject.get_node("TriggerArea").body_entered.connect(func(body): on_player_enter_key(newKeyObject, body))
		
		var newCageObject = cageObject.instantiate()
		newCageObject.position = Vector2(100, (i + 1) * 100)
		add_child(newCageObject)
		
		newCageObject.set_cage(missionObjects[i].color, i)
		newCageObject.get_node("TriggerArea").body_entered.connect(func(body): on_player_enter_cage(newCageObject, body))

func on_player_enter_key(keyObject, body):
	if body.is_in_group("Player"):
		pickUpKeys.append(keyObject.get_node_or_null("KeyData").keyType)
		keyObject.visible = false
		keyObject.set_process(false)
		keyObject.get_node("TriggerArea").set_deferred("monitoring", false)
		print("Pick up keys: ", pickUpKeys)

func on_player_enter_cage(cageObject, body):
	if body.is_in_group("Player"):
		if pickUpKeys.has(cageObject.cageType):
			await cageObject.open()
			var newPrisonner = prisonnerObject.instantiate()
			var sprite: AnimatedSprite2D = newPrisonner.get_node("AnimatedSprite2D")
			sprite.sprite_frames = missionObjects[cageObject.cageType].prisonnerSpriteFrames
			newPrisonner.position = cageObject.global_position
			add_child(newPrisonner)
			pickUpPrisonners.append(newPrisonner)
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

		if rescusePrisonnerNumber >= missionObjects.size():
			print("Mission completed")
