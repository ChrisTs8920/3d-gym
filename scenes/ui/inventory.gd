extends Control

var slot_names: Array[Label] = []
var slot_sprites: Array[Sprite2D] = []
var slots: Array[Panel] = []

# @onready var power_step: int = Player.POWER_BAR_STEP
# @onready var progress_step: float = Player.PROGRESS_STEP
# @onready var fatigue_bar: ProgressBar = $"..UI/UpperPanel/Fatigue/FatigueProgress"

func _ready() -> void:
	Dialogic.signal_event.connect(_on_bought_item)
	for i in range(1, 10):
		slot_names.append(get_node("blur_effect/GridContainer/slot%s/Panel/name" % i))
		slot_sprites.append(get_node("blur_effect/GridContainer/slot%s/Panel/sprite" % i))
		slots.append(get_node("blur_effect/GridContainer/slot%s/Panel" % i))

func _input(event: InputEvent) -> void:
	# A method that was supposed to handle item consumption with double click
	if event is InputEventMouseButton and event.is_double_click():
		pass

func _on_bought_item(bought_item_signal: String):
	# Update Inventory array, if player bought an item
	# Dialogic is the addon that handles conversation with NPCs
	if bought_item_signal == "bought_item":
		if Dialogic.VAR.item_selected != "":
			Globals.inventory[Dialogic.VAR.item_selected] = Globals.ALL_ITEMS[Dialogic.VAR.item_selected]
			Globals.inv_tooltips.append(Globals.ITEM_TOOLTIPS[Dialogic.VAR.item_selected])
			for i in range(len(Globals.inventory)):
				slot_names[i].text = Globals.inventory.keys()[i]
				slot_sprites[i].texture = Globals.inventory.values()[i]
				slots[i].tooltip_text = Globals.inv_tooltips[i]

func _on_button_pressed() -> void:
	# Back button 
	get_tree().paused = false
	hide()
	get_parent().get_node("UI").show()
	get_parent().capture_mouse()
