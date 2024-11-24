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
var power_bar_step: int = 6
var power_bar_decay: float = 0.1
var fatigue_bar_step: float = 0.1

var treadmill_progress_step: float = 0.01

var player_interacted: bool = false # Detects if player interacted with any equipment

var treadmills_entered: bool = false
const TREADMILL_TP_POS: Vector3 = Vector3(5.1, 0.5, 11) # Treadmill Position to be teleported on interact
const TREADMILL_CAM_ROT: Vector3 = Vector3(0, 90, 0) # Camera rotation on interact

@onready var camera: Camera3D = $Camera
@onready var power_bar: ProgressBar = $UI/Power/PowerProgress
@onready var fatigue_bar: ProgressBar = $UI/Fatigue/FatigueProgress

func _ready() -> void:
	capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed("interact"): _handle_interaction()
	if Input.is_action_just_pressed("power_space"): _handle_minigame()
	if Input.is_action_just_pressed("jump"): _handle_jump()
	if Input.is_action_just_pressed("exit"): _handle_exit()

func _process(delta: float) -> void:
	# Decay of progress bar - minigame mechanic
	if player_interacted and treadmills_entered:
		power_bar.value -= power_bar_decay

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
		player_interacted = true
		mouse_captured = false
		$UI/Interact.hide()
		$UI/ExitExercise.show()
		$UI/Power.show()
		camera.rotation_degrees = TREADMILL_CAM_ROT
		position = TREADMILL_TP_POS

func _handle_minigame():
	if player_interacted and treadmills_entered:
		if fatigue_bar.value < 100: # If player not fatigued
			power_bar.value += power_bar_step - Globals.treadmill_progress / 5 # progressively harder
			fatigue_bar.value += fatigue_bar_step
			if power_bar.value > 90: # If player almost maxed out power bar
				Globals.treadmill_progress += treadmill_progress_step
				Globals.treadmill_progress = clamp(Globals.treadmill_progress, 0, 10)
		else:
			_handle_exit()
		
func _handle_jump():
	if !player_interacted:
		jumping = true

func _handle_exit():
	if player_interacted:
		player_interacted = false
		mouse_captured = true
		$UI/Interact.show()
		$UI/ExitExercise.hide()
		$UI/Power.hide()
		power_bar.value = 0
	else:
		get_tree().quit()

func _on_treadmill_area_body_entered(body: Node3D) -> void:
	treadmills_entered = true

func _on_treadmill_area_body_exited(body: Node3D) -> void:
	treadmills_entered = false
