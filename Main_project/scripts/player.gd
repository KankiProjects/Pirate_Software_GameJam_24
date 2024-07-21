extends CharacterBody2D

# Constants
@export var SPEED = 700.0
@export var RUN_SPEED_MULTIPLIER = 2.1
@export var CROUCH_SPEED_MULTIPLIER = 0.5
@export var JUMP_VELOCITY = -1800.0
@export var WEIGHT = 5.0
@export var AIR_CONTROL_MULTIPLIER = 0.5  # Influence multiplier for air control
@export var ACCELERATION = 5000.0  # Acceleration when running
@export var DECELERATION_BASE = 2000.0  # Base deceleration when stopping
@export var DECELERATION_MULTIPLIER = 1.5  # Multiplier for deceleration based on speed
@export var LANDING_DECELERATION_MULTIPLIER = 3.0  # Extra deceleration when landing
@export var CROUCH_DECELERATION = 20000.0  # Deceleration when crouched
@export var DROP_THROUGH_TIME = 0.2  # Time to disable collision for drop-through
@export var PLATFORM_HEIGHT_THRESHOLD = 64.0  # Maximum height of platforms to drop through

# Imports
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D
@onready var platform_raycast = $PlatformRayCast  # Ensure this is the correct path to the RayCast2D node

# Global variables
var is_crouching = false
var current_speed
var was_in_air = false
var drop_through_timer = 0.0

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

	# Handle drop-through platform
	if drop_through_timer > 0.0:
		drop_through_timer -= delta
		if drop_through_timer <= 0.0:
			cshape.disabled = false

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")
	current_speed = SPEED

	if Input.is_action_pressed("crouch"):
		crouch()
		if on_floor and Input.is_action_pressed("down"):
			check_and_drop_through()
	else:
		stand()
	
	if is_crouching:
		current_speed *= CROUCH_SPEED_MULTIPLIER
	elif Input.is_action_pressed("run"):
		current_speed *= RUN_SPEED_MULTIPLIER

	# Apply horizontal movement with reduced influence if the character is in the air
	if on_floor:
		if direction:
			velocity.x = move_toward(velocity.x, direction * current_speed, ACCELERATION * delta)
		else:
			# Apply stronger deceleration when landing
			var effective_deceleration = DECELERATION_BASE + DECELERATION_MULTIPLIER * abs(velocity.x)
			if was_in_air:
				effective_deceleration *= LANDING_DECELERATION_MULTIPLIER
			# Apply crouch deceleration if crouching
			if is_crouching:
				effective_deceleration = CROUCH_DECELERATION
			velocity.x = move_toward(velocity.x, 0, effective_deceleration * delta)
	else:
		if direction:
			velocity.x = lerp(velocity.x, direction * current_speed, AIR_CONTROL_MULTIPLIER * delta)

	move_and_slide()

	# Update the air status for the next frame
	was_in_air = not on_floor

func crouch():
	if is_crouching:
		return
	is_crouching = true
	cshape.shape = crouching_cshape

func stand():
	if not is_crouching:
		return
	is_crouching = false
	cshape.shape = standing_cshape

func check_and_drop_through():
	platform_raycast.force_raycast_update()
	if platform_raycast.is_colliding():
		var collider = platform_raycast.get_collider()
		if collider and collider is StaticBody2D:
			var shape = collider.shape_owner_get_shape(0, 0)
			if shape and shape is RectangleShape2D:
				var rect_shape = shape as RectangleShape2D
				if rect_shape.extents.y * 2 <= PLATFORM_HEIGHT_THRESHOLD:
					drop_through()

func drop_through():
	drop_through_timer = DROP_THROUGH_TIME
	cshape.disabled = true


func _on_deadly_zone_body_entered(body):
	pass # Replace with function body.
