extends Control

var slot_names: Array[Label] = []
var slot_sprites: Array[Sprite2D] = []
var slots: Array[Panel] = []

func _ready() -> void:
	Dialogic.signal_event.connect(_on_bought_item)
	for i in range(1, 10):
		slot_names.append(get_node("blur_effect/GridContainer/slot%s/Panel/name" % i))
		slot_sprites.append(get_node("blur_effect/GridContainer/slot%s/Panel/sprite" % i))
		slots.append(get_node("blur_effect/GridContainer/slot%s/Panel" % i))

func _on_bought_item(bought_item_signal: String):
	# Update Inventory array, if player bought an item
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
	# Dialogic.Styles.get_layout_node().show()
	get_tree().paused = false
	hide()
	get_parent().get_node("UI").show()
	get_parent().capture_mouse()
