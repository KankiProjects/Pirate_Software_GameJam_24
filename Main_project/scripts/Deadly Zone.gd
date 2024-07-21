extends Area2D

func _on_deadly_zone_body_entered(body):
	if body is CharacterBody2D:  # Replace with the appropriate class if your player character has a different name
		print("Character entered deadly zone")
		restart_game()

# Function to restart the game
func restart_game():
	print("Restarting game...")
	# Directly reload the current scene
	
	await get_tree().create_timer(0.2).timeout
	get_tree().reload_current_scene()
	print("Game restarted")


