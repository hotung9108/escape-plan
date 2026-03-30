extends CharacterBody2D

var raycast: RayCast2D
var shapecast: ShapeCast2D
var player: Node2D
@export var pathSystem: Node2D
@export var mapData: Node

@export var SPEED: float = 450

var direction: Vector2
var isPlayerInRange: bool = false
enum  ENEMY_STATE {
	IDLE,
	INVESTIGATE,
	CHASE,
	PATH_FINDING
}

func _physics_process(delta: float) -> void:

	move_and_slide()
