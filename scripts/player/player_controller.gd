extends CharacterBody2D

@onready var walkingAudioPlayer: AudioStreamPlayer2D = $WalkingAudioStreamPlayer2D

@export var SPEED = 400
@export var sprint_speed_percent: float = 50.0
@export var max_stamina: float = 100.0
@export var stamina_consumption: float = 30.0
@export var stamina_regenerate_amount: float = 5.0
@export var stamina_regenerate_time: float = 0.5
@export var min_stamina_to_sprint: float = 20.0

var current_stamina: float
var is_sprinting: bool = false
var is_exhausted: bool = false
var current_dir = "down"
@export var health: int = 3

@onready var staminaRegenTimer: Timer = $StaminaRegenTimer

signal player_death()
signal init_player(health: int)
signal stamina_changed(current: float, max_val: float)

func _ready():
	$AnimatedSprite2D.play("front_idle")
	
	init_player.emit(health)
	current_stamina = max_stamina
	stamina_changed.emit(current_stamina, max_stamina)
	staminaRegenTimer.wait_time = stamina_regenerate_time
	staminaRegenTimer.timeout.connect(_on_stamina_regen_timer_timeout)

func _physics_process(delta):
	handle_movement()
	move_and_slide()

func handle_movement():
	var input_dir = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_dir.y += 1
	if Input.is_action_pressed("ui_up"):
		input_dir.y -= 1

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		
		# Exhaustion logic
		if current_stamina <= 0:
			is_exhausted = true
		if is_exhausted and current_stamina >= min_stamina_to_sprint:
			is_exhausted = false
			
		is_sprinting = Input.is_action_pressed("sprint") and not is_exhausted and current_stamina > 0
		var speed_mult = 1.0 + (sprint_speed_percent / 100.0) if is_sprinting else 1.0
		velocity = input_dir * SPEED * speed_mult
		
		if is_sprinting:
			current_stamina -= stamina_consumption * get_physics_process_delta_time()
			current_stamina = max(0, current_stamina)
			stamina_changed.emit(current_stamina, max_stamina)
		
		update_direction(input_dir)
		play_anim(true)
		if not walkingAudioPlayer.playing:
			walkingAudioPlayer.play()
	else:
		velocity = Vector2.ZERO
		is_sprinting = false
		play_anim(false)
		walkingAudioPlayer.stop()

func _on_stamina_regen_timer_timeout():
	if not is_sprinting and current_stamina < max_stamina:
		current_stamina = min(max_stamina, current_stamina + stamina_regenerate_amount)
		stamina_changed.emit(current_stamina, max_stamina)

func update_direction(dir):
	if abs(dir.x) > abs(dir.y):
		current_dir = "right" if dir.x > 0 else "left"
	else:
		current_dir = "down" if dir.y > 0 else "up"

func play_anim(moving):
	var anim = $AnimatedSprite2D

	match current_dir:
		"right":
			anim.flip_h = false
			anim.play("side_walk" if moving else "side_idle")
		"left":
			anim.flip_h = true
			anim.play("side_walk" if moving else "side_idle")
		"down":
			anim.play("front_walk" if moving else "front_idle")
		"up":
			anim.play("back_walk" if moving else "back_idle")

func deal_damge():
	health -= 1
	if health == 0:
		player_death.emit()

func toggle_debug_mode(enable: bool):
	if enable:
		get_node("Camera2D").zoom.x = 0.5
		get_node("Camera2D").zoom.y = 0.5
	else:
		get_node("Camera2D").zoom.x = 4
		get_node("Camera2D").zoom.y = 4
