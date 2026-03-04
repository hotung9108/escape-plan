extends Node

signal noise_emitted(position, intensity)

func emit_noise(pos: Vector2, intensity: float):
	noise_emitted.emit(pos, intensity)
