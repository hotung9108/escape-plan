extends CharacterBody2D

var raycast: RayCast2D
var shapecast: ShapeCast2D
var player: Node2D
var directRun: Node2D
var pathFinding: Node2D
var animatedSprite: AnimatedSprite2D

@export var mapData: Node

@export var SPEED: float = 450
@export var ATTACK_DISTANCE: float = 20

var direction: Vector2
var isPlayerInRange: bool = false
var lastDirection: Vector2 = Vector2.DOWN
var previousState: ENEMY_STATE = ENEMY_STATE.IDLE
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
	animatedSprite = get_node("AnimatedSprite2D")
	
	lastDirection = Vector2.DOWN
	if animatedSprite:
		animatedSprite.play("front_idle")

func _physics_process(delta: float):
	state_decide()
	
	do_action()
	
	update_animation()

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


func _on_vision_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		raycast.enabled = false


func _on_vision_area_body_exited(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		raycast.enabled = false

func update_animation() -> void:
	if direction != Vector2.ZERO:
		lastDirection = direction.normalized()
		update_sprite_flip()
	
	var animation_name = get_animation_name(state)
	
	if animatedSprite and animatedSprite.animation != animation_name:
		animatedSprite.play(animation_name)
	
	previousState = state

func update_sprite_flip() -> void:
	if not animatedSprite:
		return
	
	var current_animation = animatedSprite.animation
	if "side" in current_animation:
		if lastDirection.x < -0.1:
			animatedSprite.flip_h = true
		else:
			animatedSprite.flip_h = false

func get_animation_name(current_state: ENEMY_STATE) -> String:
	var direction_suffix = get_direction_suffix(lastDirection)
	
	match current_state:
		ENEMY_STATE.PATROL:
			return direction_suffix + "_walk"
		ENEMY_STATE.CHASE:
			return direction_suffix + "_run"
		ENEMY_STATE.PATH_FINDING:
			return direction_suffix + "_run"
		ENEMY_STATE.IDLE:
			return direction_suffix + "_idle"
		ENEMY_STATE.ATTACK:
			return direction_suffix + "_idle"
	
	return "front_idle"

func get_direction_suffix(dir: Vector2) -> String:
	var normalized_dir = dir.normalized()
	
	if normalized_dir.y < -0.5:
		return "back"
	elif normalized_dir.y > 0.5:
		return "front"
	else:
		return "side"
