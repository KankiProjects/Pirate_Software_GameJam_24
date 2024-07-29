extends Panel

@onready var item_visual: Sprite2D = $ItemTexture

func _ready():
	visible = true

func update(item: InventoryItem):
	print(item.name)
	if item: 
		item_visual.visible = true
		item_visual.texture = item.texture
		
