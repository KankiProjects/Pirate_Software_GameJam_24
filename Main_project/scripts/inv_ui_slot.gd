extends Panel

@onready var item_visual: Sprite2D = $ItemTexture

func update(item: InventoryItem):
	if item:
		item_visual.visible = true
		item_visual.texture = item.texture
	else:
		item_visual.visible = false
