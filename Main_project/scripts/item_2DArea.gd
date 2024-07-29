# Class Inheritance
extends Area2D

# Global variables
var can_interact = false
var interacting_body


<<<<<<< Updated upstream
=======
func _ready():
	# Connect signals programmatically
	self.body_entered.connect(_on_pickable_body_entered)
	self.body_exited.connect(_on_pickable_body_exited)

>>>>>>> Stashed changes
# Player's hitbox enters/exits 2D area
func _on_pickable_body_entered(body):
	if body.name == "Ch_Lur":
		interacting_body = body
		can_interact = true
		
		
func _on_pickable_body_exited(body):
	if body.name == "Ch_Lur":
		interacting_body = null
		can_interact = false
		


# When inside press E to collect
func _process(delta):
	if can_interact:
<<<<<<< Updated upstream
		var required_tool = interacting_body.get_ingredients()
		if required_tool["scissors"] && Input.is_action_just_pressed("interact"):
			var item_resource_path = "res://inventory/items/" + self.name + ".tres"
			var item = load(item_resource_path)
			interacting_body.collect_item(item)
			queue_free()

=======
		var required_item = interacting_body.get_ingredients()
		var item_resource_path = "res://inventory/items/" + self.name + ".tres"
		var item = load(item_resource_path)
		if self.name == "scissors":
			required_item["scissors"] = true
		if required_item["scissors"] && Input.is_action_just_pressed("interact"):
			interacting_body.collect_item(item)
			queue_free()
>>>>>>> Stashed changes
