extends CharacterBody2D

# Constants
@export var SPEED = 700.0
@export var RUN_SPEED_MULTIPLIER = 2.1
@export var CROUCH_SPEED_MULTIPLIER = 0.5
@export var JUMP_VELOCITY = -1700.0
@export var WEIGHT = 5.0
@export var AIR_CONTROL_MULTIPLIER = 0.5  # Influence multiplier for air control
@export var ACCELERATION = 2000.0  # Acceleration when running
@export var DECELERATION_BASE = 2000.0  # Base deceleration when stopping
@export var DECELERATION_MULTIPLIER = 1.5  # Multiplier for deceleration based on speed
@export var LANDING_DECELERATION_MULTIPLIER = 3.0  # Extra deceleration when landing

# Imports
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D

# Global variables
var is_crouching = false
var current_speed
var was_in_air = false

# Upload resources
var standing_cshape = preload("res://resources/standing.tres")
var crouching_cshape = preload("res://resources/crouching.tres")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	var on_floor = is_on_floor()

	# Add the gravity.
	if not on_floor:
		velocity.y += gravity * delta * WEIGHT

	# Handle jump.
	if Input.is_action_just_pressed("up") and on_floor:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")
	current_speed = SPEED
	
	if Input.is_action_pressed("run"):
		current_speed *= RUN_SPEED_MULTIPLIER
	elif Input.is_action_pressed("crouch"):
		crouch()
	else:
		stand()

	# Apply horizontal movement with reduced influence if the character is in the air
	if on_floor:
		if direction:
			velocity.x = move_toward(velocity.x, direction * current_speed, ACCELERATION * delta)
		else:
			# Apply stronger deceleration when landing
			var effective_deceleration = DECELERATION_BASE + DECELERATION_MULTIPLIER * abs(velocity.x)
			if was_in_air:
				effective_deceleration *= LANDING_DECELERATION_MULTIPLIER
			velocity.x = move_toward(velocity.x, 0, effective_deceleration * delta)
	else:
		if direction:
			velocity.x = lerp(velocity.x, direction * current_speed, AIR_CONTROL_MULTIPLIER * delta)

	move_and_slide()

	# Update the air status for the next frame
	was_in_air = not on_floor

func crouch():
	if is_crouching:
		current_speed *= CROUCH_SPEED_MULTIPLIER
		return
	is_crouching = true
	cshape.shape = crouching_cshape

func stand():
	if is_crouching == false:
		return
	is_crouching = false
	cshape.shape = standing_cshape
