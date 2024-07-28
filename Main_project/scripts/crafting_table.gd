# Class Inheritance
extends Area2D

# Global variables
var can_interact = false
var interacting_body

@onready var text1 = $Label
@onready var text2 = $Label2

# Player's hitbox enters/exits 2D area
func _on_pickable_body_entered(body):
	if body.name == "Ch_Lur":
		interacting_body = body
		can_interact = true
		
func _on_pickable_body_exited(body):
	if body.name == "Ch_Lur":
		can_interact = false

# When inside press E to collect
func _process(delta):
	pass
