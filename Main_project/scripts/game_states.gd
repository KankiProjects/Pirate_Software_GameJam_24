extends Node

# Change environment
var original_environment = null

func _ready():
	# Assuming the WorldEnvironment node is a child of the current node
	var world_environment = $WorldEnvironment

	# Check if world_environment is valid and store the original environment
	if world_environment:
		original_environment = world_environment.environment
		# Disable the WorldEnvironment element
		world_environment.environment = null
	else:
		print("WorldEnvironment node not found")

# Function to re-enable the WorldEnvironment element
func enable_environment():
	var world_environment = $WorldEnvironment
	if world_environment and original_environment:
		world_environment.environment = original_environment

# Function to disable the WorldEnvironment element
func disable_environment():
	var world_environment = $WorldEnvironment
	if world_environment:
		world_environment.environment = null
