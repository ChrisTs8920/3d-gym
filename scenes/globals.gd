extends Node

# exercise progressions | range 0 - 10
var treadmill_progress: float
var bike_progress: float
var mats_progress: float
var dumbells_progress: float
var back_machines_progress: float
var bench_press_progress: float

# Player inventory - Dictionary
var inventory = {}

var inv_tooltips = []

# All available items - Dictionary
const ALL_ITEMS = {
	"Water": preload("res://assets/Textures/icons/items/water.png"), 
	"Energy bar": preload("res://assets/Textures/icons/items/energy_bar.png"),
	"Coffee": preload("res://assets/Textures/icons/items/coffee.png"),
	"Protein": preload("res://assets/Textures/icons/items/protein.png"),
	"Creatine": preload("res://assets/Textures/icons/items/creatine.png"),
	"Towel": preload("res://assets/Textures/icons/items/towel.png"),
	"Program 1": preload("res://assets/Textures/icons/items/training_program.png")
}

# All item tooltips - Dictionary
const ITEM_TOOLTIPS = {
	"Water": "Boosts progression by 10%",
	"Energy bar": "Reduces fatigue by 30%",
	"Coffee": "Reduces fatigue by 50%",
	"Protein": "Boosts power generation by 20%",
	"Creatine": "Boosts power generation by 20%",
	"Towel": "Reduces fatigue by 20%",
	"Program 1": "Boosts progression by 20%"
}

func _ready() -> void:
	treadmill_progress = 0
	bike_progress = 0
	mats_progress = 0
	dumbells_progress = 0
	back_machines_progress = 0
	bench_press_progress = 0
