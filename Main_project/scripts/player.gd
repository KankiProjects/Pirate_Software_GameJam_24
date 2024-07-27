# Class Inheritance.
extends CharacterBody2D

# Dynamics onstants.
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

# Pushing block constants.
@export var PUSH_FORCE = 380
@export var BLOCK_MAX_VELOCITY = 370

# Imports.
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D
@onready var platform_raycast = $PlatformRayCast  # Ensure this is the correct path to the RayCast2D node
@onready var animated_Lur = $AnimationPlayer
@onready var Lur = $Lur 

# Global variables.
var crouching = false
var jumping = false
var drop_through_timer = 0.0

# Upload resources.
var standing_cshape = preload("res://resources/standing.tres")
var crouching_cshape = preload("res://resources/crouching.tres")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	stand()
	
# Handles player movement
func _physics_process(delta):
	# Resets speed.
	var current_speed = SPEED
	
	# Resets acceleration.
	var current_acceleration = 1
	
	# Checks collision bellow.
	var on_floor = is_on_floor()
	
	# Get input direction.
	var direction = Input.get_axis("left", "right")
	
	# Handle drop-through platform time.
	if drop_through_timer > 0.0:
		drop_through_timer -= delta
		if drop_through_timer <= 0.0:
			cshape.disabled = false
	
	if direction:
		# Add the gravity, apply movement, manage acceleration and trigger animations.
		if not on_floor:
			velocity.y += gravity * delta * WEIGHT
			# Arc if moving aside
			velocity.x = lerp(velocity.x, direction * current_speed, AIR_CONTROL_MULTIPLIER * delta)
			if direction:
				if direction < 0:
					animated_Lur.play("InAirBackward")
				else: animated_Lur.play("InAirForward")
			# Apply stronger deceleration when landing
			var effective_deceleration = DECELERATION_BASE + DECELERATION_MULTIPLIER * abs(velocity.x)
			effective_deceleration *= LANDING_DECELERATION_MULTIPLIER
			velocity.x = move_toward(velocity.x, 0, effective_deceleration * delta)
			animated_Lur.play("Land")
			
		else:
			# Handle input actions on floor.
			if Input.is_action_just_pressed("up"):
				velocity.y = JUMP_VELOCITY
				animated_Lur.play("Jump")
				
			elif Input.is_action_pressed("crouch"):
				if !crouching:
					crouching = true
					cshape.shape = crouching_cshape
					animated_Lur.play("CrouchIdle")
					if Input.is_action_just_pressed("down"):
						check_and_drop_through()
				else:
					crouching = false
					stand()
			
			if Input.is_action_pressed("run"):
				current_speed *= RUN_SPEED_MULTIPLIER
				current_acceleration = ACCELERATION
				animated_Lur.play("Walk")
			elif crouching:
				current_speed *= CROUCH_SPEED_MULTIPLIER
				current_acceleration = CROUCH_DECELERATION
				animated_Lur.play("CrouchWalk")
				
	velocity.x = move_toward(velocity.x, direction * current_speed, current_acceleration * delta)
		
	# Add the moving block code here.
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collision_block = collision.get_collider()
		if collision_block.is_in_group("pushable_block") and abs(collision_block.get_linear_velocity().x) < BLOCK_MAX_VELOCITY: #ensure this is the name of the group
			collision_block.apply_central_impulse(collision.get_normal() * -PUSH_FORCE)

	move_and_slide()


func stand():
	cshape.shape = standing_cshape
	animated_Lur.play("Idle")


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


func flip_x_scale(node: Node2D):
	# Check if the node has a valid scale and is not already flipped
	if node.scale and node.scale.x > 0:
		# Invert the X scale
		node.scale.x *= -1


func reset_x_scale(node: Node2D):
	# Check if the node has a valid scale and is currently flipped
	if node.scale and node.scale.x < 0:
		# Reset the X scale
		node.scale.x *= -1
