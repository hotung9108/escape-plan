extends CharacterBody2D

var raycast: RayCast2D
var player: Node2D
var directRun: Node2D
var pathFinding: Node2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $Attack/AttackArea2D
@onready var main_audio_player: AudioStreamPlayer2D = $MainAudioStreamPlayer2D
@onready var attack_effect_audio_player: AudioStreamPlayer2D = $Attack/AttackEffectAudioStreamPlayer2D

var current_direction: String = "forward"

@export var mapData: Node

@export var SPEED: float = 200
@export var ATTACK_DISTANCE: float = 28
@export var DAMAGE: int = 100
@export var ATTACK_COOLDOWN: float = 1.0

var attack_timer: float = 0.0

var direction: Vector2
enum ENEMY_STATE {
	IDLE,
	CHASE,
	PATH_FINDING
}
var state: ENEMY_STATE = ENEMY_STATE.IDLE

func _ready() -> void:
	raycast = get_node("WallRayCast2D")
	raycast.enabled = true
	raycast.collision_mask = 2
	player = get_tree().get_first_node_in_group("Player")
	mapData = get_tree().get_first_node_in_group("Map")
	directRun = get_node("DirectRun")
	pathFinding = get_node("PathFinding")
	
	attack_area.monitoring = true
	
	# If not already in a room, find the nearest one
	if pathFinding.pathSystem == null:
		var nearest = find_nearest_path_system()
		if nearest:
			enter_room(nearest)

func find_nearest_path_system() -> Node2D:
	var nearest: Node2D = null
	var min_dist_sq = INF
	for ps in mapData.all_path_systems:
		var node = ps.find_object_nearest_node(self)
		if node:
			var dist_sq = global_position.distance_squared_to(node.global_position)
			if dist_sq < min_dist_sq:
				min_dist_sq = dist_sq
				nearest = ps
	return nearest

func _physics_process(delta: float):
	if not player:
		return
		
	state_decide()
	do_action()
	update_animation()
	update_audio()
	
	if attack_timer > 0:
		attack_timer -= delta
	else:
		check_auto_attack()

func update_audio():
	if not main_audio_player.playing:
		main_audio_player.play()

func update_animation():
	var action = "idle"
	if velocity.length() > 10:
		action = "run"
		if abs(velocity.x) > abs(velocity.y):
			current_direction = "right" if velocity.x > 0 else "left"
		else:
			current_direction = "forward" if velocity.y < 0 else "backward"
	
	animated_sprite.play(current_direction + "_" + action)

func state_decide():
	var dist_sq = global_position.distance_squared_to(player.global_position)
	if dist_sq < ATTACK_DISTANCE * ATTACK_DISTANCE:
		state = ENEMY_STATE.IDLE
		return
		
	raycast.target_position = to_local(player.global_position)
	raycast.force_raycast_update()
	if raycast.is_colliding():
		if mapData.playerNeareastPoint == null:
			state = ENEMY_STATE.IDLE
			return
		if state != ENEMY_STATE.PATH_FINDING:
			pathFinding.force_recalculate(mapData.playerNeareastPoint)
		state = ENEMY_STATE.PATH_FINDING
	else:
		state = ENEMY_STATE.CHASE

func do_action():
	match state:
		ENEMY_STATE.IDLE:
			direction = Vector2.ZERO
		ENEMY_STATE.CHASE:
			direction = directRun.run()
		ENEMY_STATE.PATH_FINDING:
			direction = pathFinding.run(mapData.playerNeareastPoint)
	
	velocity = direction * SPEED
	move_and_slide()

func enter_room(room: Node2D):
	get_node("PathFinding").change_room(room)

func check_auto_attack():
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			perform_attack(body)
			break

func perform_attack(body: Node2D):
	if body.has_method("get_hit"):
		body.get_hit(DAMAGE)
		attack_timer = ATTACK_COOLDOWN
		if attack_effect_audio_player:
			attack_effect_audio_player.play()

func on_hit_player(body: Node2D):
	# This function can be called by signal or manually
	if attack_timer <= 0 and body.is_in_group("Player"):
		perform_attack(body)
