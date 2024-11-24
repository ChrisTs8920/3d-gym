extends Node3D

var board_progresses

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board_progresses = load_from_file()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$treadmill/tr_progress.text = board_progresses[int(Globals.treadmill_progress)]
	$bike/bike_progress.text = board_progresses[int(Globals.bike_progress)]
	$benchpress/bench_progress.text = board_progresses[int(Globals.bench_press_progress)]
	$mat/mat_progress.text = board_progresses[int(Globals.mats_progress)]
	$dumbells/dum_progress.text = board_progresses[int(Globals.dumbells_progress)]
	$backmachine/back_progress.text = board_progresses[int(Globals.back_machines_progress)]

func load_from_file():
	var file = FileAccess.open("res://assets/board_progress.txt", FileAccess.READ)
	var content: String = file.get_as_text()
	return content.split(",")
