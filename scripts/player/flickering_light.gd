extends PointLight2D

@export var base_energy: float = 1.0
@export var flicker_speed: float = 1
@export var flicker_intensity: float = 0.05

var time_elapsed: float = 0.0

func _ready():
	base_energy = energy

func _process(delta):
	time_elapsed += delta
	
	# Create flickering effect using sine wave + random variation
	var sine_flicker = sin(time_elapsed / flicker_speed) * flicker_intensity
	var random_flicker = randf_range(-flicker_intensity * 0.5, flicker_intensity * 0.5)
	
	energy = base_energy + sine_flicker + random_flicker
	# Clamp energy to avoid going below 0
	energy = max(0.1, energy)
