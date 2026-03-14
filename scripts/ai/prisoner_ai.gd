extends CharacterBody2D

# Dependencies
@export var player: Node2D

# Attributes
@export var DISTANCE = 10
@export var SPEED = 100.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Runtime
var state: String

func _ready():
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float):

	if player == null or player.global_position.distance_to(global_position) <= DISTANCE:
		
		if sprite.animation != "idle":
			state = "idle"
			sprite.play("idle")

		velocity = Vector2.ZERO
		return

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * SPEED

	if sprite.animation != "run":
		state = "run"
		sprite.play("run")
	
	sprite.flip_h = direction.x < 0
	
	move_and_slide()
