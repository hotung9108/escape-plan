extends TextureRect

@onready var hold_timer: Timer = Timer.new()
var fade_tween: Tween

func _ready():
	modulate.a = 0
	add_child(hold_timer)
	hold_timer.one_shot = true
	hold_timer.timeout.connect(_start_fade_out)

# Function to listen to player_health_change
func on_player_hurt(_new_health: int):
	# Stop any current fade animation
	if fade_tween:
		fade_tween.kill()
	
	if not hold_timer.is_stopped():
		# Already holding, just stack time
		var current_time = hold_timer.time_left
		hold_timer.start(current_time + 2.0)
	else:
		# Either off or fading, so fade in and hold
		fade_tween = create_tween()
		fade_tween.tween_property(self, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_SINE)
		fade_tween.finished.connect(_start_hold)

func _start_hold():
	hold_timer.start(2.0)

func _start_fade_out():
	if fade_tween:
		fade_tween.kill()
		
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE)
