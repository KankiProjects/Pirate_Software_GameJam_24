# Class inheritance
extends Control

@onready var inv: Inventory = preload("res://inventory/inventory.tres")
@onready var slots: Array = $GridContainer.get_children()

func _ready():
	visible = true

func update_slots():
	for i in range(min(inv.items.size(), slots.size())):
		slots[i].update(inv.items[i])

func _process(delta):
	pass
