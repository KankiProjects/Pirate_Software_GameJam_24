# Class inheritance
extends Control

@onready var inv: Inventory = preload("res://inventory/inventory.tres")
@onready var slots: Array = $GridContainer.get_children()

# Declare global variables
var is_open = false

# Prevents signal issues when parent enters scene
func _ready():
	close()

func update_slots():
	for i in range(min(inv.items.size(), slots.size())):
		slots[i].update(inv.items[i])

func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		if is_open: close()
		else: open()
	
func open():
	visible = true
	is_open = true

func close():
	visible = false
	is_open = false
