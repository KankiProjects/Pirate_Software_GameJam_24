# Class Inheritance.
extends CharacterBody2D

# Dynamics constants.
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
@export var CROUCH_OFFSET = Vector2(0, 1) # Vertical offset for crouching

# Pushing block constants.
@export var PUSH_FORCE = 380
@export var BLOCK_MAX_VELOCITY = 370

# Imports.
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D
@onready var platform_raycast = $PlatformRayCast  # Ensure this is the correct path to the RayCast2D node
@onready var animated_Lur = $AnimationPlayer
@onready var invUI = $Lur/Camera2D/InventoryUI
@onready var Lur = $Lur 

# Upload resources.
var standing_cshape = preload("res://resources/standing_polygon.tres")
var crouching_cshape = preload("res://resources/crouching_polygon.tres")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Global variables.
var corrected_crouch_shape
var original_shape_pos
var crouching = false
var prev_velocity_y = 0.0
var drop_through_timer = 0.0

# Collectable ingredients
var ingredients = {
	"nut" : false,
 	"scissors" : false,
 	"leaf" : false,
	"mushroom" : false,
	"flower" : false,
 	"ginseng_root" : false,
 	"mandrake_root" : false,
 	"rose_water" : false
}


# Plays idle anim when program starts.
func _ready():
	corrected_crouch_shape = cshape.position + CROUCH_OFFSET
	original_shape_pos = cshape.position
	stand()


# Handles player dynamics every frame.
func _physics_process(delta):
	# Resets speed.
	var current_speed = SPEED
	
	# Resets acceleration.
	var current_acceleration = ACCELERATION
	
	# Checks collision bellow.
	var on_floor = is_on_floor()
	
	# Get input direction.
	var direction = Input.get_axis("left", "right")

	
	# Handle drop-through platform time.
	if drop_through_timer > 0.0:
		drop_through_timer -= delta
		if drop_through_timer <= 0.0:
			cshape.disabled = false
			stand()


	# Handle movement, acceleration and trigger animations.
	if not on_floor:
		crouching = false
		# Add gravity.
		velocity.y += gravity * delta * WEIGHT
		if direction:
			# Arc properly if moving aside in air.
			velocity.x = lerp(velocity.x, direction * current_speed, AIR_CONTROL_MULTIPLIER * delta)
			if direction < 0:
				animated_Lur.play("InAirBackward")
			else: animated_Lur.play("InAirForward")

	else: # Handle input actions on floor.

		if Input.is_action_just_pressed("up"):
			velocity.y = JUMP_VELOCITY
			animated_Lur.play("Jump")
			
		elif Input.is_action_pressed("crouch"):
			if not crouching:
				crouching = true
				cshape.shape = crouching_cshape
				cshape.position = corrected_crouch_shape
				animated_Lur.play("CrouchIdle")
				# Platform raycast logic.
				if Input.is_action_just_pressed("down"):
					check_and_drop_through()
				
		if Input.is_action_just_released("crouch"):
				crouching = false
				stand()
	
		if direction:
			if Input.is_action_pressed("run") && !crouching: 
				current_speed *= RUN_SPEED_MULTIPLIER
			if crouching: 
				current_speed *= CROUCH_SPEED_MULTIPLIER
				current_acceleration = CROUCH_DECELERATION
				animated_Lur.play("CrouchWalk")
			else: animated_Lur.play("Walk")
			velocity.x = move_toward(velocity.x, direction * current_speed, current_acceleration * delta)
		else:
			# Apply stronger deceleration when landing
			current_acceleration = DECELERATION_BASE + DECELERATION_MULTIPLIER * abs(velocity.x)
			# Checks if the player has landed.
			if prev_velocity_y < 0 && velocity.y >= 0:
				current_acceleration *= LANDING_DECELERATION_MULTIPLIER
			velocity.x = move_toward(velocity.x, 0, current_acceleration * delta)
			if not crouching: stand()
			else: animated_Lur.play("CrouchIdle")

	# Add the moving block code here.
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collision_block = collision.get_collider()
		if collision_block.is_in_group("pushable_block") and abs(collision_block.get_linear_velocity().x) < BLOCK_MAX_VELOCITY: #ensure this is the name of the group
			collision_block.apply_central_impulse(collision.get_normal() * -PUSH_FORCE)

	# Perform physics and modifies velocity values.
	move_and_slide()

	# Store last vertical velocity value.
	prev_velocity_y = velocity.y


func stand():
	cshape.shape = standing_cshape
	cshape.position = original_shape_pos
	animated_Lur.play("Idle")


func check_and_drop_through():
	platform_raycast.force_raycast_update()
	if platform_raycast.is_colliding():
		var collider = platform_raycast.get_collider()
		if collider is StaticBody2D:
			var shape = collider.shape_owner_get_shape(0, 0)
			if shape is RectangleShape2D:
				var rect_shape = shape as RectangleShape2D
				if rect_shape.extents.y * 2 <= PLATFORM_HEIGHT_THRESHOLD:
					drop_through()


func drop_through():
	drop_through_timer = DROP_THROUGH_TIME
	cshape.disabled = true
  
  
# Handle item interaction and collection
func collect_item(item):
	if !ingredients[item.name]:
		ingredients[item.name] = true
		for i in range(len(invUI.inv.items)):
			if invUI.inv.items[i] == null:
				invUI.inv.items[i] = item
				invUI.update_slots()
				break


func get_ingredients():
	return ingredients
