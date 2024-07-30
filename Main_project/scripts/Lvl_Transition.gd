extends Area2D

# Exported variable to set the scene ID
@export var scene_id: int

# Dictionary to map scene IDs to scene paths
var scene_paths = {
	11: "res://scenes/Sc1_Lvl1.1_Alchemy.tscn",
	12: "res://scenes/Sc1_Lvl1.2_Narrative.tscn",
	221: "res://scenes/Sc2_Lvl2.2.1_Platform.tscn",
	222: "res://scenes/Sc2_Lvl2.2.2_Narrative.tscn",
	223: "res://scenes/Sc2_Lvl2.2.3_Platform.tscn"
}

# Variable to check if the player is inside the area
var player_in_area = false

# Path to the new scene to load
var new_scene_path: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set the new_scene_path based on the scene_id
	if scene_paths.has(scene_id):
		new_scene_path = scene_paths[scene_id]
	else:
		print("Invalid scene ID: ", scene_id)

# Function to handle when a body enters the area
func _on_body_entered(body):
	player_in_area = true
	print(player_in_area)

# Function to handle when a body exits the area
func _on_body_exited(body):
	player_in_area = false
	print(player_in_area)

# Function to check for the interact input
func _process(delta):
	if player_in_area == true and Input.is_action_just_pressed("interact"):  # "interact" is the action for interactio
		get_tree().change_scene_to_file(new_scene_path)
