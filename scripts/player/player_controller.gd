extends CharacterBody2D

const SPEED = 400
var current_dir = "down"
@export var health: int = 3

signal player_death()
signal init_player(health: int)

func _ready():
	$AnimatedSprite2D.play("front_idle")
	
	init_player.emit(health)

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
		velocity = input_dir * SPEED
		update_direction(input_dir)
		play_anim(true)
	else:
		velocity = Vector2.ZERO
		play_anim(false)

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
