extends Path2D


@export var loop = true
@export var speed = 2.0
@export var speed_scale = 1.0
@export var invert = false

@onready var path = $PathFollow2D
@onready var animation = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	if not loop:
		animation.play("moving_platform_1")
		animation.speed_scale = speed_scale
		set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if invert == false:
		path.progress += speed
	else:
		path.progress_ratio = 0.0
		path.progress -= speed
