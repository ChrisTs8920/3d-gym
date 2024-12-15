extends Control

const DEFAULT_TEXT: String = "Exercise with "

const TREADMILLS_TEXT: String = "treadmills"
const BIKES_TEXT: String = "bikes"
const MATS_TEXT: String = "mats"
const DUMBELLS_TEXT: String = "dumbells"
const BACKMACHINE_TEXT: String = "back machines"
const BENCHPRESS_TEXT: String = "bench press"

const DOOR_TEXT: String = "Leave the gym and rest"

const s_panel = Vector2(260, 55)
const m_panel = Vector2(300, 55)
const l_panel = Vector2(330, 55)
const xl_panel = Vector2(350, 55)

func _on_treadmills_entered(body: Node3D) -> void:
	$LowerPanel.show()
	$LowerPanel.size = m_panel
	$LowerPanel/Interact.text = DEFAULT_TEXT + TREADMILLS_TEXT
	$LowerPanel/Interact.show()


func _on_treadmills_exited(body: Node3D) -> void:
	$LowerPanel.hide()
	$LowerPanel/Interact.hide()


func _on_bike_area_body_entered(body: Node3D) -> void:
	$LowerPanel.show()
	$LowerPanel.size = s_panel
	$LowerPanel/Interact.text = DEFAULT_TEXT + BIKES_TEXT
	$LowerPanel/Interact.show()


func _on_bike_exited(body: Node3D) -> void:
	$LowerPanel.hide()
	$LowerPanel/Interact.hide()


func _on_mat_entered(body: Node3D) -> void:
	$LowerPanel.show()
	$LowerPanel.size = s_panel
	$LowerPanel/Interact.text = DEFAULT_TEXT + MATS_TEXT
	$LowerPanel/Interact.show()


func _on_mat_exited(body: Node3D) -> void:
	$LowerPanel.hide()
	$LowerPanel/Interact.hide()


func _on_dumbell_entered(body: Node3D) -> void:
	$LowerPanel.show()
	$LowerPanel.size = m_panel
	$LowerPanel/Interact.text = DEFAULT_TEXT + DUMBELLS_TEXT
	$LowerPanel/Interact.show()


func _on_dumbell_exited(body: Node3D) -> void:
	$LowerPanel.hide()
	$LowerPanel/Interact.hide()


func on_back_machines_entered(body: Node3D) -> void:
	$LowerPanel.show()
	$LowerPanel.size = xl_panel
	$LowerPanel/Interact.text = DEFAULT_TEXT + BACKMACHINE_TEXT
	$LowerPanel/Interact.show()


func _on_back_machines_exited(body: Node3D) -> void:
	$LowerPanel.hide()
	$LowerPanel/Interact.hide()


func _on_bench_press_entered(body: Node3D) -> void:
	$LowerPanel.show()
	$LowerPanel.size = l_panel
	$LowerPanel/Interact.text = DEFAULT_TEXT + BENCHPRESS_TEXT
	$LowerPanel/Interact.show()


func _on_bench_press_exited(body: Node3D) -> void:
	$LowerPanel.hide()
	$LowerPanel/Interact.hide()


func _on_door_entered(body: Node3D) -> void:
	$LowerPanel.show()
	$LowerPanel.size = l_panel
	$LowerPanel/Interact.text = DOOR_TEXT
	$LowerPanel/Interact.show()


func _on_door_exited(body: Node3D) -> void:
	$LowerPanel.hide()
	$LowerPanel/Interact.hide()
