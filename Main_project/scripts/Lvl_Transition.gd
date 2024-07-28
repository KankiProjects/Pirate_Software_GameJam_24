extends Area2D

# Path to the new scene to load
@export var new_scene_path: String = "res://scenes/Sc2_Lvl2.2.1_Platform.tscn"

# Variable to check if the player is inside the area
var player_in_area = false

# Function to handle when a body enters the area
func _on_body_entered(body: PhysicsBody2D):
	if body.name == "Player":  # Replace "Player" with the name of your player node
		player_in_area = true

# Function to handle when a body exits the area
func _on_body_exited(body: PhysicsBody2D):
	if body.name == "Player":  # Replace "Player" with the name of your player node
		player_in_area = false

# Function to check for the interact input
func _process(delta):
	if player_in_area and Input.is_action_just_pressed("ui_accept"):  # "ui_accept" is usually the Enter key or Spacebar
		get_tree().change_scene_to_file(new_scene_path)
