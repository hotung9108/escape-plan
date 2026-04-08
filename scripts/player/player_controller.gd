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
var is_dead: bool = false
@export var health: int = 3
@export var shake_intensity: float = 5.0
@export var shake_duration: float = 0.2

@onready var staminaRegenTimer: Timer = $StaminaRegenTimer
@onready var hitAudioPlayer: AudioStreamPlayer2D = $HitAudioStreamPlayer2D

signal player_health_change(health: int)
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
	
	# Preload hit sound
	hitAudioPlayer.stream = preload("res://assets/sounds/mc-hurt.mp3")

func _physics_process(delta):
	handle_movement()
	move_and_slide()

func handle_movement():
	if is_dead:
		return
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
		walkingAudioPlayer.pitch_scale = speed_mult
	else:
		velocity = Vector2.ZERO
		is_sprinting = false
		play_anim(false)
		walkingAudioPlayer.stop()
		walkingAudioPlayer.pitch_scale = 1.0

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

func get_hit(damage: int):
	if is_dead:
		return
		
	health -= damage
	if health <= 0:
		health = 0
		is_dead = true
		velocity = Vector2.ZERO
		walkingAudioPlayer.stop()
		$AnimatedSprite2D.play("death")
		player_health_change.emit(health)
		shake_camera()
		hitAudioPlayer.play()
		await $AnimatedSprite2D.animation_finished
		await get_tree().create_timer(2.0).timeout
		player_death.emit()
	else:
		player_health_change.emit(health)
		shake_camera()
		hitAudioPlayer.play()

func shake_camera():
	var camera = $Camera2D
	if camera:
		var tween = create_tween()
		var shake_count = 10
		var time_per_shake = shake_duration / shake_count
		
		for i in range(shake_count):
			var rand_offset = Vector2(
				randf_range(-shake_intensity, shake_intensity),
				randf_range(-shake_intensity, shake_intensity)
			)
			tween.tween_property(camera, "offset", rand_offset, time_per_shake)
		
		# Return to original position
		tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)

func toggle_debug_mode(enable: bool):
	get_node("PointLight2D").visible = !enable
	
	if enable:
		get_node("Camera2D").zoom.x = 0.5
		get_node("Camera2D").zoom.y = 0.5
	else:
		get_node("Camera2D").zoom.x = 4
		get_node("Camera2D").zoom.y = 4
