class_name Player extends CharacterBody3D

# Variables for movement and camera controls
@export_category("Player")
@export_range(1, 35, 1) var speed: float = 10 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

var jumping: bool = false
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity


# Variables for interaction and minigames
const POWER_BAR_STEP: int = 12
const POWER_BAR_DECAY: float = 0.2
const FATIGUE_BAR_STEP: float = 0.1
const PROGRESS_STEP: float = 0.01

var player_interacted: bool = false # Detects if player interacted with any equipment

# Treadmills
var treadmills_entered: bool = false
const TREADMILL_TP_POS: Vector3 = Vector3(5.1, 0.6, 11) # Treadmill Position to be teleported on interact
const TREADMILL_CAM_ROT: Vector3 = Vector3(0, 90, 0) # Camera rotation on interact

# Bikes
var bikes_entered: bool = false
const BIKE_TP_POS: Vector3 = Vector3(-7.9, 0.6, 11)
const BIKE_CAM_ROT: Vector3 = Vector3(0, 90, 0)

# Bench press
var bench_press_entered: bool = false
const BENCH_TP_POS: Vector3 = Vector3(-13, 0, 3.8)
const BENCH_CAM_ROT: Vector3 = Vector3(90, 180, 0)
var next_key_minigame: String = "q_minigame" # Initial key is 'q'
# var reps: int = 0

@onready var camera: Camera3D = $Camera
@onready var power_bar: ProgressBar = $UI/UpperPanel/Power/PowerProgress
@onready var fatigue_bar: ProgressBar = $UI/UpperPanel/Fatigue/FatigueProgress
@onready var minigame_1_label: Label = $UI/UpperPanel/Power/Minigame1_label
@onready var minigame_2_label: Label = $UI/UpperPanel/Power/Minigame2_label

func _ready() -> void:
	capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed("interact"): _handle_interaction()
	if Input.is_action_just_pressed("space_minigame"): _handle_minigame_1()
	if Input.is_action_just_pressed(next_key_minigame): _handle_minigame_2()
	if Input.is_action_just_pressed("jump"): _handle_jump()
	if Input.is_action_just_pressed("exit"): _handle_exit()

func _process(delta: float) -> void:
	# Decay of progress bar - minigame mechanic
	if player_interacted:
		decay_power_bar()

func decay_power_bar():
	# Decay for minigame 1
	if treadmills_entered or bikes_entered:
		power_bar.value -= POWER_BAR_DECAY
	# Decay for minigame 2
	if bench_press_entered:
		if power_bar.value == 100:
			next_key_minigame = "helper_minigame" # Does not allow the player to interact - Rep completed
		if power_bar.value == 0:
			next_key_minigame = "q_minigame" # Allow player to interact - Rep reset
		power_bar.value -= POWER_BAR_DECAY * 2 # Faster bar decay

func _physics_process(delta: float) -> void:
	if not player_interacted: # Allow movement only when player has not interacted with anything
		if mouse_captured: _handle_joypad_camera_rotation(delta)
		velocity = _walk(delta) + _gravity(delta) + _jump(delta)
		move_and_slide()

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

#func release_mouse() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#mouse_captured = false

func _rotate_camera(sens_mod: float = 1.0) -> void:
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector("look_left","look_right","look_up","look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		look_dir = Vector2.ZERO

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

func _handle_interaction():
	if treadmills_entered:
		_interaction_logic(TREADMILL_CAM_ROT, TREADMILL_TP_POS, minigame_1_label)
	if bikes_entered:
		_interaction_logic(BIKE_CAM_ROT, BIKE_TP_POS, minigame_1_label)
	if bench_press_entered:
		_interaction_logic(BENCH_CAM_ROT, BENCH_TP_POS, minigame_2_label)

func _interaction_logic(cam_rotation, tp_pos, info_label):
	player_interacted = true
	mouse_captured = false
	$UI/LowerPanel/Interact.hide()
	$UI/LowerPanel/ExitExercise.show()
	$UI/UpperPanel/Power.show()
	info_label.show()
	$UI/UpperPanel.size = Vector2(520, 160)
	camera.rotation_degrees = cam_rotation
	position = tp_pos

func _handle_minigame_1():
	if player_interacted and (treadmills_entered or bikes_entered):
		if fatigue_bar.value < 100: # If player not fatigued
			power_bar.value += POWER_BAR_STEP - Globals.treadmill_progress / 2 # progressively harder
			fatigue_bar.value += FATIGUE_BAR_STEP
			if power_bar.value > 90: # If player almost maxed out power bar, progress category
				_handle_progression()
		else:
			_handle_exit()

func _handle_minigame_2():
	if player_interacted and bench_press_entered:
		if fatigue_bar.value < 100: # If player not fatigued
			power_bar.value += POWER_BAR_STEP - Globals.bench_press_progress / 2 # progressively harder
			fatigue_bar.value += FATIGUE_BAR_STEP
			# Count reps
			if power_bar.value == 100:
				# reps += 1
				_handle_progression()
			
			# Alternate between q and e - minigame mechanic
			if next_key_minigame == "q_minigame":
				next_key_minigame = "e_minigame"
			elif next_key_minigame == "e_minigame":
				next_key_minigame = "q_minigame"
		else:
			next_key_minigame = "q_minigame" # Reset starting key
			_handle_exit()

func _handle_progression():
	if treadmills_entered:
		Globals.treadmill_progress += PROGRESS_STEP
		Globals.treadmill_progress = clamp(Globals.treadmill_progress, 0, 10)
	if bikes_entered:
		Globals.bike_progress += PROGRESS_STEP
		Globals.bike_progress = clamp(Globals.bike_progress, 0, 10)
	if bench_press_entered:
		Globals.bench_press_progress += PROGRESS_STEP * 10 # Progress by 0.1 every rep
		Globals.bike_progress = clamp(Globals.bike_progress, 0, 10)

func _handle_jump():
	if !player_interacted:
		jumping = true

func _handle_exit():
	if player_interacted:
		player_interacted = false
		mouse_captured = true
		$UI/LowerPanel/ExitExercise.hide()
		$UI/LowerPanel/Interact.show()
		$UI/UpperPanel/Power.hide()
		minigame_1_label.hide()
		minigame_2_label.hide()
		$UI/UpperPanel.size = Vector2(280, 50)
		power_bar.value = 0
	else:
		get_tree().quit()

func _on_treadmill_area_body_entered(body: Node3D) -> void:
	treadmills_entered = true

func _on_treadmill_area_body_exited(body: Node3D) -> void:
	treadmills_entered = false


func _on_bike_area_body_entered(body: Node3D) -> void:
	bikes_entered = true

func _on_bike_area_body_exited(body: Node3D) -> void:
	bikes_entered = false


func _on_benchpress_area_body_entered(body: Node3D) -> void:
	bench_press_entered = true

func _on_benchpress_area_body_exited(body: Node3D) -> void:
	bench_press_entered = false
