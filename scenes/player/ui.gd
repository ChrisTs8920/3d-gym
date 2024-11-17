extends Control

const DEFAULT_TEXT = "Exercise with "

const TREADMILLS_TEXT = "treadmills"
const BIKES_TEXT = "bikes"
const MATS_TEXT = "mats"
const DUMBELLS_TEXT = "dumbells"
const BACKMACHINE_TEXT = "back machines"
const BENCHPRESS_TEXT = "bench press"

const DOOR_TEXT = "Leave the gym and rest"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_treadmills_entered(body: Node3D) -> void:
	$Interact.text = DEFAULT_TEXT + TREADMILLS_TEXT
	$Interact.show()


func _on_treadmills_exited(body: Node3D) -> void:
	$Interact.hide()


func _on_bike_area_body_entered(body: Node3D) -> void:
	$Interact.text = DEFAULT_TEXT + BIKES_TEXT
	$Interact.show()


func _on_bike_exited(body: Node3D) -> void:
	$Interact.hide()


func _on_mat_entered(body: Node3D) -> void:
	$Interact.text = DEFAULT_TEXT + MATS_TEXT
	$Interact.show()


func _on_mat_exited(body: Node3D) -> void:
	$Interact.hide()


func _on_dumbell_entered(body: Node3D) -> void:
	$Interact.text = DEFAULT_TEXT + DUMBELLS_TEXT
	$Interact.show()


func _on_dumbell_exited(body: Node3D) -> void:
	$Interact.hide()


func on_back_machines_entered(body: Node3D) -> void:
	$Interact.text = DEFAULT_TEXT + BACKMACHINE_TEXT
	$Interact.show()


func _on_back_machines_exited(body: Node3D) -> void:
	$Interact.hide()


func _on_bench_press_entered(body: Node3D) -> void:
	$Interact.text = DEFAULT_TEXT + BENCHPRESS_TEXT
	$Interact.show()


func _on_bench_press_exited(body: Node3D) -> void:
	$Interact.hide()


func _on_door_entered(body: Node3D) -> void:
	$Interact.text = DOOR_TEXT
	$Interact.show()


func _on_door_exited(body: Node3D) -> void:
	$Interact.hide()
