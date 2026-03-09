extends Node

# Attributes 
@export var keyObjects: Array[Color] = []

# Resources
var keyObject = preload("res://scenes/mission/key_object.tscn")
var cageObject = preload("res://scenes/mission/cage_object.tscn")

# Runtime vars
var pickUpKeys: Array[int] = []

func _ready():
	for i in range(keyObjects.size()):
		var newKeyObject = keyObject.instantiate()
		newKeyObject.position = Vector2(0, (i + 1) * 50)
		add_child(newKeyObject)
		
		newKeyObject.get_node_or_null("KeyData").keyType = i
		newKeyObject.modulate = keyObjects[i]
		newKeyObject.get_node("TriggerArea").body_entered.connect(func(body): on_player_enter_key(newKeyObject, body))
		
		var newCageObject = cageObject.instantiate()
		newCageObject.position = Vector2(100, (i + 1) * 100)
		add_child(newCageObject)
		
		newCageObject.set_cage(keyObjects[i], i)
		newCageObject.get_node("TriggerArea").body_entered.connect(func(body): on_play_enter_cage(newCageObject, body))

func on_player_enter_key(keyObject, body):
	pickUpKeys.append(keyObject.get_node_or_null("KeyData").keyType)
	keyObject.visible = false
	keyObject.set_process(false)
	keyObject.get_node("TriggerArea").set_deferred("monitoring", false)
	print("Pick up keys: ", pickUpKeys)

func on_play_enter_cage(cageObject, body):
	if pickUpKeys.has(cageObject.cageType):
		cageObject.open()
	else:
		cageObject.interact()
