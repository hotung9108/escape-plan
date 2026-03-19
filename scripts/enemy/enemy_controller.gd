extends CharacterBody2D

var raycast: RayCast2D
var shapecast: ShapeCast2D
var player: Node2D
@export var pathSystem: PathSystem
@export var mapData: Node

@export var SPEED: float = 100.0

var direction: Vector2
var isPlayerInRange: bool = false
enum  ENEMY_STATE {
	IDLE,
	CHASE,
	PATH_FINDING
}
var state: ENEMY_STATE = ENEMY_STATE.IDLE
var currentNode: Node2D

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
			shapecast.enabled = true
			shapecast.target_position = to_local(player.global_position)
			shapecast.force_shapecast_update()
			if shapecast.is_colliding():
				if state != ENEMY_STATE.PATH_FINDING:
					currentNode = pathSystem.find_object_nearest_node(self)
					get_node("PathFinding").nextNode = currentNode
				state = ENEMY_STATE.PATH_FINDING
			else:
				state = ENEMY_STATE.CHASE
			shapecast.enabled = false
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
			if abs(position.x - pathFinding.nextNode.position.x) <= 2 and abs(position.y - pathFinding.nextNode.position.y) <= 2:
				currentNode = pathFinding.nextNode
				
			direction = pathFinding.run(currentNode, mapData.playerNeareastPoint)
	
	velocity = direction * SPEED
	
	move_and_slide()

func _on_trigger_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		raycast.enabled = true

func _on_trigger_area_body_exited(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		raycast.enabled = false
