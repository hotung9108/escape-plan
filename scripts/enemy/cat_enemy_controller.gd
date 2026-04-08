extends CharacterBody2D

var raycast: RayCast2D
var shapecast: ShapeCast2D
var player: Node2D
var directRun: Node2D
var pathFinding: Node2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_animated_sprite: AnimatedSprite2D = $Attack/AttackAnimatedSprite2D
@onready var attack_area: Area2D = $Attack/AttackArea2D
@onready var main_audio_player: AudioStreamPlayer2D = $MainAudioStreamPlayer2D
@onready var attack_audio_player: AudioStreamPlayer2D = $AttackAudioStreamPlayer2D
@onready var attack_effect_audio_player: AudioStreamPlayer2D = $Attack/AttackEffectAudioStreamPlayer2D

var current_direction: String = "forward"

@export var mapData: Node

@export var SPEED: float = 450
@export var ATTACK_DISTANCE: float = 20
@export var ATTACK_COOLDOWN: float = 1.0
@export var DAMAGE: int = 1

var can_attack: bool = true
var _hit_bodies: Array[Node2D] = []

var direction: Vector2
var isPlayerInRange: bool = false
enum ENEMY_STATE {
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
	
	animated_sprite.animation_finished.connect(_on_animation_finished)
	# Ensure attack animations don't loop
	for anim in ["forward_attack", "backward_attack", "left_attack", "right_attack"]:
		if animated_sprite.sprite_frames.has_animation(anim):
			animated_sprite.sprite_frames.set_animation_loop(anim, false)
	
	attack_animated_sprite.animation_finished.connect(_on_attack_effect_finished)
	attack_animated_sprite.visible = false
	attack_area.monitoring = false

func _on_animation_finished():
	if state == ENEMY_STATE.ATTACK:
		state = ENEMY_STATE.IDLE
		get_tree().create_timer(ATTACK_COOLDOWN).timeout.connect(func(): can_attack = true)

func _on_attack_effect_finished():
	attack_animated_sprite.visible = false
	attack_area.monitoring = false
	_hit_bodies.clear()

func _trigger_attack_effect():
	_hit_bodies.clear()
	attack_animated_sprite.visible = true
	attack_animated_sprite.play("attack")
	attack_area.monitoring = true
	attack_effect_audio_player.play()
	
	# Handle players already in the attack area immediately
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape_node = attack_area.get_child(0) as CollisionShape2D
	query.shape = shape_node.shape
	query.transform = shape_node.global_transform
	query.collision_mask = attack_area.collision_mask
	
	var results = space_state.intersect_shape(query)
	for result in results:
		on_hit_player(result.collider)

func _physics_process(delta: float):
	state_decide()
	
	do_action()
	update_animation()
	update_audio()

func update_audio():
	if state == ENEMY_STATE.ATTACK:
		if main_audio_player.playing:
			main_audio_player.stop()
	else:
		if not main_audio_player.playing:
			main_audio_player.play()

func update_animation():
	var action = "idle"
	if state == ENEMY_STATE.ATTACK:
		action = "attack"
	elif velocity.length() > 10:
		action = "run"
		if abs(velocity.x) > abs(velocity.y):
			current_direction = "right" if velocity.x > 0 else "left"
		else:
			current_direction = "forward" if velocity.y < 0 else "backward"
	
	animated_sprite.play(current_direction + "_" + action)

func update_direction_to_point(target_pos: Vector2):
	var diff = target_pos - global_position
	if abs(diff.x) > abs(diff.y):
		current_direction = "right" if diff.x > 0 else "left"
	else:
		current_direction = "forward" if diff.y < 0 else "backward"

func state_decide():
	if state == ENEMY_STATE.ATTACK:
		return
	if raycast.enabled:
		raycast.target_position = to_local(player.global_position)
		raycast.force_raycast_update()
		if raycast.is_colliding():
			if state != ENEMY_STATE.PATH_FINDING:
				pathFinding.force_update_transform()
			state = ENEMY_STATE.PATH_FINDING
		else:
			if player.position.distance_squared_to(position) < ATTACK_DISTANCE * ATTACK_DISTANCE:
				if can_attack:
					if state != ENEMY_STATE.ATTACK:
						update_direction_to_point(player.global_position)
						state = ENEMY_STATE.ATTACK
						can_attack = false
						attack_audio_player.play()
						get_tree().create_timer(0.5).timeout.connect(_trigger_attack_effect)
				else:
					state = ENEMY_STATE.IDLE
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

func on_hit_player(body: Node2D):
	if body in _hit_bodies:
		return
		
	if (body.is_in_group("Player")):
		_hit_bodies.append(body)
		if body.has_method("get_hit"):
			body.get_hit(DAMAGE)
