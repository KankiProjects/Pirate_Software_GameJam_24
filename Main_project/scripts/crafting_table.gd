# Class Inheritance
extends Area2D

# Global variables
var can_interact = false
var interacting_body
var required_items

@onready var text1 = $Label
@onready var text2 = $Label2
@onready var cshape = $CollisionShape2D


func _ready():
	text1.visible = false
	text2.visible = false
	cshape.visible = false


# Player's hitbox enters/exits 2D area
func _on_pickable_body_entered(body):
	if body.name == "Ch_Lur":
		interacting_body = body
		text1.visible = true
		can_interact = true

		
		
func _on_pickable_body_exited(body):
	if body.name == "Ch_Lur":
		interacting_body = null
		can_interact = false
		text1.visible = false
		text2.visible = false



# When inside press E to collect
func _process(delta):
	if can_interact:
		check_required_items()
		
		
func check_required_items():
	required_items = interacting_body.get_ingredients()
	if required_items["betle_nut"] && required_items["betle_leaf"] && required_items["scissors"]:
		if Input.is_action_just_pressed("interact"):
			interacting_body.set_ingredients()
			
			text1.visible = false
	elif Input.is_action_just_pressed("interact"):
		text1.visible = false
		text2.visible = true
		
