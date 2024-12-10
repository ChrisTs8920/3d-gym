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
var next_key_minigame_2: String = "q_minigame" # Initial key is 'q'

# Dumbells
var dumbells_entered: bool = false
const DUMBELLS_TP_POS: Vector3 = Vector3(8.6, 0.5, 1.1)
const DUMBELLS_CAM_ROT: Vector3 = Vector3(-30, 174, 0)

# Mats
var mats_entered: bool = false
const MATS_TP_POS: Vector3 = Vector3(9.7, 0, -7.4)
const MATS_CAM_ROT: Vector3 = Vector3(0, -90, 0)
const W_KEY_INT: int = 0
const A_KEY_INT: int = 1
const S_KEY_INT: int = 2
const D_KEY_INT: int = 3
var next_key: int = randi_range(W_KEY_INT, D_KEY_INT)

# Back machines
var back_machines_entered: bool = false
const BACK_TP_POS: Vector3 = Vector3(-2.5, 0.5, 2.6)
const BACK_CAM_ROT: Vector3 = Vector3(0, 90, 0)

@onready var camera: Camera3D = $Camera
@onready var power_bar: ProgressBar = $UI/UpperPanel/Power/PowerProgress
@onready var fatigue_bar: ProgressBar = $UI/UpperPanel/Fatigue/FatigueProgress
@onready var minigame_1_label: Label = $UI/UpperPanel/Power/Minigame1_label
@onready var minigame_2_label: Label = $UI/UpperPanel/Power/Minigame2_label
@onready var minigame_3_label: Label = $UI/UpperPanel/Power/Minigame3_label

func _ready() -> void:
	capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	# Interact
	if Input.is_action_just_pressed("interact"): _handle_interaction()
	# Minigame 1
	if Input.is_action_just_pressed("minigame_1"): _handle_minigame_1()
	# Minigame 2
	if Input.is_action_just_pressed(next_key_minigame_2): _handle_minigame_2()
	# Minigame 3
	if Input.is_action_just_pressed("w_minigame_3"): _handle_minigame_3("w")
	if Input.is_action_just_pressed("a_minigame_3"): _handle_minigame_3("a")
	if Input.is_action_just_pressed("s_minigame_3"): _handle_minigame_3("s")
	if Input.is_action_just_pressed("d_minigame_3"): _handle_minigame_3("d")
	# Other actions
	if Input.is_action_just_pressed("jump"): _handle_jump()
	if Input.is_action_just_pressed("exit"): _handle_exit()

func _process(delta: float) -> void:
	# Decay of progress bar - minigame mechanic
	if player_interacted:
		decay_power_bar()
	
	if mats_entered or back_machines_entered:
		if next_key == 0:
			$UI/MiddlePanel/wkey.modulate = Color(1, 1, 1, 1)
			$UI/MiddlePanel/akey.modulate = Color(1, 1, 1, 0.5)
			$UI/MiddlePanel/skey.modulate = Color(1, 1, 1, 0.5)
			$UI/MiddlePanel/dkey.modulate = Color(1, 1, 1, 0.5)
		elif next_key == 1:
			$UI/MiddlePanel/akey.modulate = Color(1, 1, 1, 1)
			$UI/MiddlePanel/wkey.modulate = Color(1, 1, 1, 0.5)
			$UI/MiddlePanel/skey.modulate = Color(1, 1, 1, 0.5)
			$UI/MiddlePanel/dkey.modulate = Color(1, 1, 1, 0.5)
		elif next_key == 2:
			$UI/MiddlePanel/skey.modulate = Color(1, 1, 1, 1)
			$UI/MiddlePanel/wkey.modulate = Color(1, 1, 1, 0.5)
			$UI/MiddlePanel/akey.modulate = Color(1, 1, 1, 0.5)
			$UI/MiddlePanel/dkey.modulate = Color(1, 1, 1, 0.5)
		elif next_key == 3:
			$UI/MiddlePanel/dkey.modulate = Color(1, 1, 1, 1)
			$UI/MiddlePanel/akey.modulate = Color(1, 1, 1, 0.5)
			$UI/MiddlePanel/skey.modulate = Color(1, 1, 1, 0.5)
			$UI/MiddlePanel/wkey.modulate = Color(1, 1, 1, 0.5)

func decay_power_bar():
	# Decay for minigame 1
	if treadmills_entered or bikes_entered:
		power_bar.value -= POWER_BAR_DECAY
	# Decay for minigame 2
	if bench_press_entered or dumbells_entered:
		if power_bar.value == 100:
			next_key_minigame_2 = "helper_minigame" # Does not allow the player to interact - Rep completed
		if power_bar.value == 0:
			next_key_minigame_2 = "q_minigame" # Allow player to interact - Rep reset
		power_bar.value -= POWER_BAR_DECAY * 2 # Faster bar decay
	# Decay for minigame 3
	if mats_entered or back_machines_entered:
		power_bar.value -= POWER_BAR_DECAY

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
	if dumbells_entered:
		_interaction_logic(DUMBELLS_CAM_ROT, DUMBELLS_TP_POS, minigame_2_label)
	if mats_entered:
		_interaction_logic(MATS_CAM_ROT, MATS_TP_POS, minigame_3_label)
	if back_machines_entered:
		_interaction_logic(BACK_CAM_ROT, BACK_TP_POS, minigame_3_label)

func _interaction_logic(cam_rotation, tp_pos, info_label):
	player_interacted = true
	mouse_captured = false
	$UI/LowerPanel/Interact.hide()
	$UI/LowerPanel/ExitExercise.show()
	$UI/UpperPanel/Power.show()
	info_label.show()
	$UI/UpperPanel.size = Vector2(520, 160)
	if mats_entered or back_machines_entered:
		$UI/MiddlePanel.show()
	camera.rotation_degrees = cam_rotation
	position = tp_pos

func _handle_minigame_1():
	if player_interacted and (treadmills_entered or bikes_entered):
		if fatigue_bar.value < 100: # If player not fatigued
			if treadmills_entered:
				power_bar.value += POWER_BAR_STEP - Globals.treadmill_progress / 2  # progressively harder
			elif bikes_entered:
				power_bar.value += POWER_BAR_STEP - Globals.bike_progress / 2
			fatigue_bar.value += FATIGUE_BAR_STEP
			if power_bar.value >= 90: # If player almost maxed out power bar, progress category
				_handle_progression()
		else:
			_handle_exit()

func _handle_minigame_2():
	if player_interacted and (bench_press_entered or dumbells_entered):
		if fatigue_bar.value < 100: # If player not fatigued
			if bench_press_entered:
				power_bar.value += POWER_BAR_STEP - Globals.bench_press_progress / 2 # progressively harder
			elif dumbells_entered:
				power_bar.value += POWER_BAR_STEP - Globals.dumbells_progress / 2
			fatigue_bar.value += FATIGUE_BAR_STEP
			if power_bar.value == 100:
				_handle_progression()
			
			# Alternate between q and e - minigame mechanic
			if next_key_minigame_2 == "q_minigame":
				next_key_minigame_2 = "e_minigame"
			elif next_key_minigame_2 == "e_minigame":
				next_key_minigame_2 = "q_minigame"
		else:
			next_key_minigame_2 = "q_minigame" # Reset starting key
			_handle_exit()

func _handle_minigame_3(key_pressed: String):
	if player_interacted and (mats_entered or back_machines_entered):
		if fatigue_bar.value < 100: # If player not fatigued
			if key_pressed == "w":
				if next_key == 0:
					power_bar.value += (POWER_BAR_STEP * 2) - Globals.mats_progress / 2 # progressively harder
					next_key = randi_range(W_KEY_INT, D_KEY_INT)
					fatigue_bar.value += FATIGUE_BAR_STEP
				else: # On wrong key press, reduce power bar
					power_bar.value -= (POWER_BAR_STEP * 2) + Globals.mats_progress / 2
					fatigue_bar.value += FATIGUE_BAR_STEP
			elif key_pressed == "a":
				if next_key == 1:
					power_bar.value += (POWER_BAR_STEP * 2) - Globals.mats_progress / 2 # progressively harder
					next_key = randi_range(W_KEY_INT, D_KEY_INT)
					fatigue_bar.value += FATIGUE_BAR_STEP
				else: # On wrong key press, reduce power bar
					power_bar.value -= (POWER_BAR_STEP * 2) + Globals.mats_progress / 2
					fatigue_bar.value += FATIGUE_BAR_STEP
			elif key_pressed == "s":
				if next_key == 2:
					power_bar.value += (POWER_BAR_STEP * 2) - Globals.mats_progress / 2 # progressively harder
					next_key = randi_range(W_KEY_INT, D_KEY_INT)
					fatigue_bar.value += FATIGUE_BAR_STEP
				else: # On wrong key press, reduce power bar
					power_bar.value -= (POWER_BAR_STEP * 2) + Globals.mats_progress / 2
					fatigue_bar.value += FATIGUE_BAR_STEP
			elif key_pressed == "d":
				if next_key == 3:
					power_bar.value += (POWER_BAR_STEP * 2) - Globals.mats_progress / 2 # progressively harder
					next_key = randi_range(W_KEY_INT, D_KEY_INT)
					fatigue_bar.value += FATIGUE_BAR_STEP
				else: # On wrong key press, reduce power bar
					power_bar.value -= (POWER_BAR_STEP * 2) + Globals.mats_progress / 2
					fatigue_bar.value += FATIGUE_BAR_STEP
			if power_bar.value >= 80: # If player almost maxed out power bar, progress category
				_handle_progression()
		else:
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
		Globals.bench_press_progress = clamp(Globals.bench_press_progress, 0, 10)
	if dumbells_entered:
		Globals.dumbells_progress += PROGRESS_STEP * 10 # Progress by 0.1 every rep
		Globals.dumbells_progress = clamp(Globals.dumbells_progress, 0, 10)
	if mats_entered:
		Globals.mats_progress += PROGRESS_STEP
		Globals.mats_progress = clamp(Globals.mats_progress, 0, 10)
	if back_machines_entered:
		Globals.back_machines_progress += PROGRESS_STEP
		Globals.back_machines_progress = clamp(Globals.back_machines_progress, 0, 10)

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
		$UI/MiddlePanel.hide()
		minigame_1_label.hide()
		minigame_2_label.hide()
		minigame_3_label.hide()
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


func _on_dumbell_area_body_entered(body: Node3D) -> void:
	dumbells_entered = true

func _on_dumbell_area_body_exited(body: Node3D) -> void:
	dumbells_entered = false


func _on_mat_area_body_entered(body: Node3D) -> void:
	mats_entered = true

func _on_mat_area_body_exited(body: Node3D) -> void:
	mats_entered = false


func _on_back_machines_area_body_entered(body: Node3D) -> void:
	back_machines_entered = true

func _on_back_machines_area_body_exited(body: Node3D) -> void:
	back_machines_entered = false
