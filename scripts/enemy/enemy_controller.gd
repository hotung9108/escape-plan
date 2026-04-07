extends CharacterBody2D

var raycast: RayCast2D
var shapecast: ShapeCast2D
var player: Node2D
var directRun: Node2D
var pathFinding: Node2D

@export var mapData: Node

@export var SPEED: float = 450
@export var ATTACK_DISTANCE: float = 20

var direction: Vector2
var isPlayerInRange: bool = false
enum  ENEMY_STATE {
	IDLE,
	CHASE,
	PATH_FINDING,
	ATTACK,
	PATROL
}
var state: ENEMY_STATE = ENEMY_STATE.IDLE

func _ready() -> void:
	raycast = get_node("WallRayCast2D")
	shapecast = get_node("WallShapeCast2D")
	raycast.enabled = false 
	raycast.collision_mask = 2
	player = get_tree().get_first_node_in_group("Player")
	mapData = get_tree().get_first_node_in_group("Map")
	directRun = get_node("DirectRun")
	pathFinding = get_node("PathFinding")

func _physics_process(delta: float):
	state_decide()
	
	do_action()

func state_decide():
	if raycast.enabled:
		raycast.target_position = to_local(player.global_position)
		raycast.force_raycast_update()
		if raycast.is_colliding():
			if state != ENEMY_STATE.PATH_FINDING:
				pathFinding.force_update_transform()
			state = ENEMY_STATE.PATH_FINDING
		else:
			if player.position.distance_squared_to(position) < ATTACK_DISTANCE * ATTACK_DISTANCE:
				state = ENEMY_STATE.ATTACK
			else:
				state = ENEMY_STATE.CHASE
	else:
		state = ENEMY_STATE.PATROL

func do_action():
	match state:
		ENEMY_STATE.PATROL:
			direction = pathFinding.patrol()
		ENEMY_STATE.IDLE:
			direction = Vector2.ZERO
			
		ENEMY_STATE.ATTACK:
			direction = Vector2.ZERO
		ENEMY_STATE.CHASE:
			direction = directRun.run()
		
		ENEMY_STATE.PATH_FINDING:
			direction = pathFinding.run(mapData.playerNeareastPoint)
	
	velocity = direction * SPEED
	move_and_slide()

func _on_trigger_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		raycast.enabled = true

func _on_trigger_area_body_exited(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		raycast.enabled = false

func enter_room(room: Node2D):
	get_node("PathFinding").change_room(room)
