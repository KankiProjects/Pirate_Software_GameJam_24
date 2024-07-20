# Class Inheritance
extends Area2D

# Global variables
var can_interact = false
var interacting_body

# Player's hitbox enters/exits 2D area
func _on_pickable_body_entered(body):
	if body.name == "character":
		interacting_body = body
		can_interact = true
		
func _on_pickable_body_exited(body):
	if body.name == "character":
		can_interact = false

# When inside press E to collect
func _process(delta):
	if can_interact && Input.is_action_just_pressed("interact"):
		interacting_body.collect_item(self)
		queue_free()
