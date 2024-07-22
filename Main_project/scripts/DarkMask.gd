extends Sprite2D

# Variables to control the speed of scaling down, the initial size, and the minimum size
@export var shrink_speed = 0.0
@export var initial_scale = Vector2(11, 11)  # Initial scale values for x and y
@export var min_scale = Vector2(1, 1)  # Minimum scale values for x and y

func _ready():
	# Set the initial scale of the sprite
	scale = initial_scale

func _process(delta):
	# Reduce the scale of the sprite gradually
	if scale.x > min_scale.x or scale.y > min_scale.y:
		scale -= Vector2(shrink_speed, shrink_speed) * delta
		
		# Ensure the scale does not become smaller than min_scale
		if scale.x < min_scale.x:
			scale.x = min_scale.x
		if scale.y < min_scale.y:
			scale.y = min_scale.y
