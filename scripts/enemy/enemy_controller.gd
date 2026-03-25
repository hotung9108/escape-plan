extends CharacterBody2D

var raycast: RayCast2D
var shapecast: ShapeCast2D
var player: Node2D
@export var pathSystem: Node2D
@export var mapData: Node

@export var SPEED: float = 450

var direction: Vector2
var isPlayerInRange: bool = false
enum  ENEMY_STATE {
	IDLE,
	CHASE,
	PATH_FINDING
}
var state: ENEMY_STATE = ENEMY_STATE.IDLE
@export var currentNode: Node2D

func _ready() -> void:
	raycast = get_node("WallRayCast2D")
	shapecast = get_node("WallShapeCast2D")
	raycast.enabled = false 
	raycast.collision_mask = 2
	player = get_tree().get_first_node_in_group("Player")
	currentNode = pathSystem.find_object_nearest_node(self)
	get_node("PathFinding").nextNode = currentNode
	mapData = get_tree().get_first_node_in_group("Map")

func _physics_process(delta: float):
	state_decide()
	
	do_action()

func state_decide():
	if raycast.enabled:
		raycast.target_position = to_local(player.global_position)
		raycast.force_raycast_update()
		if raycast.is_colliding():
			if state != ENEMY_STATE.PATH_FINDING:
				currentNode = pathSystem.find_object_nearest_node(self)
				get_node("PathFinding").nextNode = currentNode
			state = ENEMY_STATE.PATH_FINDING
			
		else:
			state = ENEMY_STATE.CHASE
			#shapecast.enabled = true
			#shapecast.target_position = to_local(player.global_position)
			#shapecast.force_shapecast_update()
			#if shapecast.is_colliding():
				#if state != ENEMY_STATE.PATH_FINDING:
					#currentNode = pathSystem.find_object_nearest_node(self)
					#get_node("PathFinding").nextNode = currentNode
				#state = ENEMY_STATE.PATH_FINDING
			#else:
			#shapecast.enabled = false
	else:
		state = ENEMY_STATE.IDLE

func do_action():
	match state:
		ENEMY_STATE.IDLE:
			direction = Vector2.ZERO
		
		ENEMY_STATE.CHASE:
			direction = get_node("DirectRun").run()
		
		ENEMY_STATE.PATH_FINDING:
			var pathFinding = get_node("PathFinding")
			
			if pathFinding.nextNode == null:
				direction = Vector2.ZERO
				return
			
			var dist_to_current = position.distance_to(currentNode.position)
			
			# ✅ Case 1: Not at currentNode yet - keep moving to it
			if dist_to_current > 3:
				direction = position.direction_to(currentNode.position)
			
			# ✅ Case 2: At currentNode, but nextNode is different - update and move
			elif currentNode != pathFinding.nextNode:
				currentNode = pathFinding.nextNode
				direction = position.direction_to(currentNode.position)
			
			# ✅ Case 3: At currentNode and it's up to date - get next path
			else:
				direction = pathFinding.run(currentNode, mapData.playerNeareastPoint)
	
	velocity = direction * SPEED
	move_and_slide()

func _on_trigger_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		raycast.enabled = true

func _on_trigger_area_body_exited(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		raycast.enabled = false

func enter_room(room: Node2D):
	pathSystem = room
