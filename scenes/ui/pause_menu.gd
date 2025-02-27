extends Control

@onready var obj1_count: Label = $blur_effect/objectives_opt/reach50_any/count
@onready var obj2_count: Label = $blur_effect/objectives_opt/reach100_all/count

@onready var obj1: Label = $blur_effect/objectives_opt/reach50_any
@onready var obj2: Label = $blur_effect/objectives_opt/reach100_all

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_evaluate_obj1()
	_evaluate_obj2()
	_highlight_obj(obj1_count, obj1)
	_highlight_obj(obj2_count, obj2)
		
func _evaluate_obj1():
	# If any exercise reaches 50%, complete objective
	if (Globals.treadmill_progress >= 5 
	or Globals.bike_progress >= 5 
	or Globals.mats_progress >= 5 
	or Globals.dumbells_progress >= 5
	or Globals.back_machines_progress >= 5
	or Globals.bench_press_progress >= 5):
		obj1_count.text[0] = "1"

func _evaluate_obj2():
	# If all exercises reach 100%, complete objective
	var tmp: int = (Globals.treadmill_progress / 10
	+ Globals.bike_progress / 10
	+ Globals.mats_progress / 10
	+ Globals.dumbells_progress / 10
	+ Globals.back_machines_progress / 10
	+ Globals.bench_press_progress / 10)
	obj2_count.text[0] = str(tmp)

func _highlight_obj(obj_count: Label, obj: Label):
	# If player completed optional objective, highlight it with yellow
	if obj_count.text[0] == obj_count.text[obj_count.text.length() - 1]:
		obj_count.modulate = Color(1, 1, 0, 1)
		obj.modulate = Color(1, 1, 0, 1)

func _on_resume_button_pressed() -> void:
	# Unpause
	get_tree().paused = false
	hide() # Hide pause menu
	get_parent().get_node("UI").show()
	get_parent().capture_mouse()


func _on_exit_button_pressed() -> void:
	# Exit game
	get_tree().quit()
