extends CharacterBody2D

var raycast: RayCast2D
var shapecast: ShapeCast2D
var player: Node2D
var directRun: Node2D
var pathFinding: Node2D
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_animated_sprite: AnimatedSprite2D = $Attack/AttackAnimatedSprite2D
@onready var attack_area: Area2D = $Attack/AttackArea2D
@onready var main_audio_player: AudioStreamPlayer2D = $MainAudioStreamPlayer2D
@onready var attack_audio_player: AudioStreamPlayer2D = $AttackAudioStreamPlayer2D
@onready var attack_effect_audio_player: AudioStreamPlayer2D = $Attack/AttackEffectAudioStreamPlayer2D
@onready var attack_object: Node2D = $Attack
@onready var detect_area: Area2D = $VisionArea

@export var mapData: Node

@export var SPEED: float = 450
@export var ATTACK_DISTANCE: float = 50
@export var ATTACK_COOLDOWN: float = 2.0
@export var DAMAGE: int = 1

var can_attack: bool = true
var can_change_to_path_finding: bool = false
var _hit_bodies: Array[Node2D] = []

var direction: Vector2
var isPlayerInRange: bool = false
var lastDirection: Vector2 = Vector2.DOWN
var previousState: ENEMY_STATE = ENEMY_STATE.IDLE
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
	
	lastDirection = Vector2.DOWN
	if animatedSprite:
		animatedSprite.play("front_idle")
	
	# Attack initialization
	attack_animated_sprite.visible = false
	attack_area.monitoring = false
	attack_animated_sprite.animation_finished.connect(_on_attack_animation_finished)
	attack_area.body_entered.connect(on_hit_player)
	
	if main_audio_player:
		main_audio_player.play()

func _physics_process(delta: float):
	state_decide()
	
	do_action()
	
	update_animation()

func state_decide():
	# If currently performing an attack animation, don't change state
	if not can_attack and attack_animated_sprite.visible:
		return
		
	if raycast.enabled:
		raycast.target_position = to_local(player.global_position)
		raycast.force_raycast_update()
		
		# If we have direct line of sight, we gain the ability to use path finding
		var looking_direct = !raycast.is_colliding()
		if looking_direct:
			can_change_to_path_finding = true
			
		if can_change_to_path_finding:
			if player.position.distance_squared_to(position) < ATTACK_DISTANCE * ATTACK_DISTANCE:
				if can_attack:
					state = ENEMY_STATE.ATTACK
				else:
					state = ENEMY_STATE.IDLE
			elif looking_direct:
				state = ENEMY_STATE.CHASE
			else:
				if mapData.playerNeareastPoint == null:
					state = ENEMY_STATE.IDLE
					return
				if state != ENEMY_STATE.PATH_FINDING:
					pathFinding.force_update_transform()
				state = ENEMY_STATE.PATH_FINDING
		else:
			# In detect area but haven't seen player directly yet
			state = ENEMY_STATE.PATROL
	else:
		# Out of detect area, reset detection flag and patrol
		can_change_to_path_finding = false
		state = ENEMY_STATE.PATROL

func do_action():
	match state:
		ENEMY_STATE.PATROL:
			direction = pathFinding.patrol()
		ENEMY_STATE.IDLE:
			direction = Vector2.ZERO
			
		ENEMY_STATE.ATTACK:
			direction = Vector2.ZERO
			if can_attack:
				start_attack()
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
		raycast.enabled = true


func _on_vision_area_body_exited(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		raycast.enabled = false
		can_change_to_path_finding = false

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
			return direction_suffix + "_attack"
	
	return "front_idle"

func get_direction_suffix(dir: Vector2) -> String:
	var normalized_dir = dir.normalized()
	
	if normalized_dir.y < -0.5:
		return "back"
	elif normalized_dir.y > 0.5:
		return "front"
	else:
		return "side"

func on_hit_player(body: Node2D):
	if body in _hit_bodies:
		return
		
	if (body.is_in_group("Player")):
		_hit_bodies.append(body)
		if body.has_method("get_hit"):
			body.get_hit(DAMAGE)

func start_attack():
	can_attack = false
	_hit_bodies.clear()
	
	# Move attack object to player position
	attack_object.global_position = player.global_position
	
	# Visuals
	attack_animated_sprite.visible = true
	attack_animated_sprite.play("attack") # Assuming "attack" is the name
	
	# Audio
	if attack_audio_player:
		attack_audio_player.play()
	if attack_effect_audio_player:
		attack_effect_audio_player.play()
	if main_audio_player:
		main_audio_player.stop()
		
	# Timing: Delay activate attack area 0.5 sec
	await get_tree().create_timer(0.5).timeout
	
	if not is_inside_tree(): return
	
	# Collision On
	attack_area.monitoring = true
	
	# Immediate check for overlapping players
	var overlapping = attack_area.get_overlapping_bodies()
	for body in overlapping:
		on_hit_player(body)
		if not _hit_bodies.is_empty():
			break # Attack first player found per attack
			
	# Timing: Hold attack area 0.75 sec
	await get_tree().create_timer(0.75).timeout
	
	if not is_inside_tree(): return
	
	# Collision Off
	attack_area.monitoring = false

func _on_attack_animation_finished():
	attack_animated_sprite.visible = false
	attack_area.monitoring = false
	
	if main_audio_player:
		main_audio_player.play()
	
	# Transition state after attack
	state = ENEMY_STATE.IDLE
	
	# Handle cooldown
	await get_tree().create_timer(ATTACK_COOLDOWN).timeout
	can_attack = true
