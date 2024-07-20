# Class inheritance
extends CharacterBody2D

# Constants
const SPEED = 200.0
const RUN_SPEED_MULTIPLIER = 1.5
const CROUCH_SPEED_MULTIPLIER = 0.5
const JUMP_VELOCITY = -300.0

# Imports
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D

# Global variables
var is_crouching = false
var current_speed

# Upload resources
var standing_cshape = preload("res://resources/standing.tres")
var crouching_cshape = preload("res://resources/crouching.tres")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")
	current_speed = SPEED 
	
	if Input.is_action_pressed("run"):
		current_speed *= RUN_SPEED_MULTIPLIER
	elif Input.is_action_pressed("crouch"):
		crouch()
	else: stand()
	
	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed * delta * 3.5)
	
	move_and_slide()

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
