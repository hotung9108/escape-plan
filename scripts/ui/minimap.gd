extends Control

@onready var minimap_camera: Camera2D = $MarginContainer/SubViewportContainer/SubViewport/Camera2D
@onready var sub_viewport: SubViewport = $MarginContainer/SubViewportContainer/SubViewport

var player: Node2D

func _ready() -> void:
    # Set the minimap to use the same World2D as the main game
    sub_viewport.world_2d = get_viewport().world_2d
    
    # Delay finding the player slightly until the scene is fully loaded
    call_deferred("_find_player")

func _find_player() -> void:
    var players = get_tree().get_nodes_in_group("Player")
    if players.size() > 0:
        player = players[0]

func _process(_delta: float) -> void:
    if player != null:
        minimap_camera.global_position = player.global_position
