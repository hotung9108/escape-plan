extends CharacterBody2D

enum State {
	PATROL,
	INVESTIGATE,
	CHASE,
	SEARCH,
	RETURN_HOME
}

@export var patrol_speed := 100
@export var chase_speed := 220
@export var investigate_speed := 150

@export var vision_distance := 250
@export var hearing_range := 400

@onready var nav_agent = $NavigationAgent2D
@onready var raycast = $RayCast2D

var state = State.PATROL

var player
var home_room
var investigate_position
var last_seen_position
var search_timer := 0.0

func _ready():
	player = get_tree().get_first_node_in_group("player")

	if player == null:
		push_error("Player not found in group 'player'")

	NoiseManager.noise_emitted.connect(_on_noise)
	pick_home_room()

func pick_home_room():
	var rooms = get_tree().get_nodes_in_group("rooms")
	if rooms.is_empty():
		push_error("No rooms found in group 'rooms'")
		return
	
	home_room = rooms.pick_random()
	nav_agent.target_position = home_room.global_position

func _physics_process(delta):

	match state:
		State.PATROL:
			patrol()
		State.INVESTIGATE:
			investigate()
		State.CHASE:
			chase()
		State.SEARCH:
			search(delta)
		State.RETURN_HOME:
			return_home()

	move_along_path()

	check_vision()

func move_along_path():
	if nav_agent.is_navigation_finished():
		return
	
	var next_pos = nav_agent.get_next_path_position()
	var dir = (next_pos - global_position).normalized()
	velocity = dir * get_current_speed()
	move_and_slide()

func get_current_speed():
	match state:
		State.CHASE:
			return chase_speed
		State.INVESTIGATE:
			return investigate_speed
		_:
			return patrol_speed

# =========================
# PATROL
# =========================
func patrol():
	if nav_agent.is_navigation_finished():
		nav_agent.target_position = home_room.global_position

# =========================
# INVESTIGATE
# =========================
func investigate():
	if nav_agent.is_navigation_finished():
		state = State.RETURN_HOME

# =========================
# CHASE
# =========================
func chase():
	if player == null:
		return
	
	nav_agent.target_position = player.global_position

	if not can_see_player():
		last_seen_position = player.global_position
		nav_agent.target_position = last_seen_position
		state = State.SEARCH

# =========================
# SEARCH
# =========================
func search(delta):
	search_timer += delta
	
	if search_timer > 3:
		search_timer = 0
		state = State.RETURN_HOME

# =========================
# RETURN HOME
# =========================
func return_home():
	nav_agent.target_position = home_room.global_position
	
	if global_position.distance_to(home_room.global_position) < 10:
		state = State.PATROL

# =========================
# VISION
# =========================
func check_vision():
	if player == null:
		return
	
	if can_see_player():
		state = State.CHASE

func can_see_player():
	if global_position.distance_to(player.global_position) > vision_distance:
		return false

	raycast.target_position = to_local(player.global_position)
	raycast.force_raycast_update()

	if raycast.is_colliding():
		return raycast.get_collider() == player

	return false

# =========================
# NOISE
# =========================
func _on_noise(pos, intensity):
	if state == State.CHASE:
		return
	
	var dist = global_position.distance_to(pos)
	
	if dist < hearing_range * intensity:
		investigate_position = pos
		nav_agent.target_position = pos
		state = State.INVESTIGATE
