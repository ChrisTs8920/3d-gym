extends Node

# range 0 - 10
var treadmill_progress: float
var bike_progress: float
var mats_progress: float
var dumbells_progress: float
var back_machines_progress: float
var bench_press_progress: float

func _ready() -> void:
	treadmill_progress = 0
	bike_progress = 0
	mats_progress = 0
	dumbells_progress = 0
	back_machines_progress = 0
	bench_press_progress = 0
