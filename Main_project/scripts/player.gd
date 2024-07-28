extends CharacterBody2D

# Constants
@export var SPEED = 400.0
@export var RUN_SPEED_MULTIPLIER = 2.1
@export var CROUCH_SPEED_MULTIPLIER = 0.7
@export var JUMP_VELOCITY = -1500.0
@export var WEIGHT = 5.0
@export var AIR_CONTROL_MULTIPLIER = 0.5  # Influence multiplier for air control
@export var ACCELERATION = 2000.0  # Acceleration when running
@export var DECELERATION_BASE = 2000.0  # Base deceleration when stopping
@export var DECELERATION_MULTIPLIER = 1.5  # Multiplier for deceleration based on speed
@export var LANDING_DECELERATION_MULTIPLIER = 3.0  # Extra deceleration when landing
@export var CROUCH_DECELERATION = 20000.0  # Deceleration when crouched
@export var DROP_THROUGH_TIME = 0.2  # Time to disable collision for drop-through
@export var PLATFORM_HEIGHT_THRESHOLD = 64.0  # Maximum height of platforms to drop through

# Pushing block constants
@export var PUSH_FORCE = 380
@export var BLOCK_MAX_VELOCITY = 370

# Imports
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D
@onready var platform_raycast = $PlatformRayCast  # Ensure this is the correct path to the RayCast2D node
@onready var animated_Lur = $AnimationPlayer
@onready var Lur = $Lur 

# Global variables
var is_crouching = false
var current_speed
var jumping_state = false
var was_in_air = false
var drop_through_timer = 0.0

# Upload resources
var standing_cshape = preload("res://resources/standing_polygon.tres")
var crouching_cshape = preload("res://resources/crouching_polygon.tres")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	cshape.shape = standing_cshape

func _input(event):
	
	var any_key_pressed = false  # Variable to track if any key is pressed
	
	if event is InputEventKey and event.pressed:
		any_key_pressed = true
	elif event is InputEventKey and not event.pressed:
		any_key_pressed = false
	
	animate_Lur(event, any_key_pressed)

func _physics_process(delta):
	
	var on_floor = is_on_floor()

	# Add the gravity.
	if not on_floor:
		velocity.y += gravity * delta * WEIGHT
		jumping_state = true
	else:
		jumping_state = false

	# Handle jump.
	if Input.is_action_just_pressed("up") and on_floor:
		velocity.y = JUMP_VELOCITY
		print("Character jumped")

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
		
		animated_Lur.play("CrouchIdle")
		
		if on_floor and Input.is_action_pressed("down"):
			check_and_drop_through()
	else:
		stand()
	
	if is_crouching:
		current_speed *= CROUCH_SPEED_MULTIPLIER
		print("Character is crouching")
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

	# Add the move block code here
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collision_block = collision.get_collider()
		if collision_block.is_in_group("pushable_block") and abs(collision_block.get_linear_velocity().x) < BLOCK_MAX_VELOCITY: #ensure this is the name of the group
			collision_block.apply_central_impulse(collision.get_normal() * -PUSH_FORCE)

	move_and_slide()
	# print("Character position: ", global_position)

	# Update the air status for the next frame
	was_in_air = not on_floor

func crouch():
	if is_crouching:
		return
	is_crouching = true
	cshape.shape = crouching_cshape
	print("Character crouched")

func stand():
	if not is_crouching:
		return
	is_crouching = false
	cshape.shape = standing_cshape
	print("Character stood up")

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
	print("Character dropping through platform")


func animate_Lur(event, any_key_pressed):
	var current_state = "idle"
	var input_state = current_state  # Default to current state
	
	# Determine the current input state
	if any_key_pressed == true:
		if jumping_state:
			if Input.is_action_pressed("left"):
				input_state = "in_air_backward"
			elif Input.is_action_pressed("right"):
				input_state = "in_air_forward"
			else:
				input_state = "jump"
		elif was_in_air and not jumping_state:
			input_state = "land"
			was_in_air = false  # Reset the was_in_air flag
		else:
			if Input.is_action_just_pressed("up"):
				input_state = "jump"
			elif Input.is_action_just_pressed("left"):
				if Input.is_action_pressed("crouch"):
					input_state = "crouch_walk_left"
				elif Input.is_action_pressed("run"):
					input_state = "run_walk_left"
				else:
					input_state = "walk_left"
			elif Input.is_action_just_pressed("right"):
				if Input.is_action_pressed("crouch"):
					input_state = "crouch_walk_right"
				elif Input.is_action_pressed("run"):
					input_state = "run_walk_right"
				else:
					input_state = "walk_right"
			elif Input.is_action_pressed("crouch"):
				if current_state == "crouch_walk_left" or current_state == "crouch_walk_right":
					input_state = "crouch_idle"
			elif Input.is_action_pressed("run"):
				if Input.is_action_just_pressed("left"):
					input_state = "run_walk_left"
				if Input.is_action_just_pressed("right"):
					input_state = "run_walk_right"
	else:
		input_state = "idle"
	
	# Check if the input state has changed
	if input_state != current_state:
		current_state = input_state
		# Use match statement to handle the input states
		match input_state:
			"jump":
				animated_Lur.play("Jump")
				was_in_air = true
			"walk_left":
				flip_x_scale(Lur)
				animated_Lur.play("Walk")
			"walk_right":
				reset_x_scale(Lur)
				animated_Lur.play("Walk")
			"crouch_walk_left":
				flip_x_scale(Lur)
				animated_Lur.play("CrouchWalk")
			"crouch_walk_right":
				reset_x_scale(Lur)
				animated_Lur.play("CrouchWalk")
			"run_walk_left":
				flip_x_scale(Lur)
				animated_Lur.speed_scale = RUN_SPEED_MULTIPLIER
				animated_Lur.play("Walk")
			"run_walk_right":
				reset_x_scale(Lur)
				animated_Lur.speed_scale = RUN_SPEED_MULTIPLIER
				animated_Lur.play("Walk")
			"crouch_idle":
				animated_Lur.play("CrouchIdle")
			"in_air_backward":
				reset_x_scale(Lur)
				animated_Lur.play("InAirBackward")
			"in_air_forward":
				reset_x_scale(Lur)
				animated_Lur.play("InAirForward")
			"land":
				animated_Lur.play("Land")
			"idle":
				animated_Lur.play("Idle")

func flip_x_scale(node: Node2D):
	# Check if the node has a valid scale and is not already flipped
	if node.scale and node.scale.x > 0:
		# Invert the X scale
		node.scale.x *= -1
		print("X scale of ", node.name, " flipped to ", node.scale.x)

func reset_x_scale(node: Node2D):
	# Check if the node has a valid scale and is currently flipped
	if node.scale and node.scale.x < 0:
		# Reset the X scale
		node.scale.x *= -1
		print("X scale of ", node.name, " reset to ", node.scale.x)
