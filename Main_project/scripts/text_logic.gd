extends Control

# Export variables for the animation and fade durations
@export var animation_duration = 2.0
@export var fade_duration = 1.0

# Define variables for the RichTextLabel nodes and the fade ColorRect
var prelude1
var prelude2
var fade_rect

# Variables to track the current animation progress
var animation_progress = 0.0
var current_animation = 1
var animation_finished = false

func _ready():
	# Get references to the RichTextLabel nodes and the fade ColorRect
	prelude1 = $prelude1
	prelude2 = $prelude2
	fade_rect = $FadeRect

	# Initialize prelude2 as hidden
	prelude2.visible = false

	# Initialize fade_rect
	fade_rect.color = Color(0, 0, 0, 0)  # Fully transparent initially

	# Start the animation for prelude1
	start_animation(prelude1)

func _process(delta):
	if not animation_finished:
		animation_progress += delta / animation_duration
		if current_animation == 1:
			prelude1.visible_ratio = animation_progress
		elif current_animation == 2:
			prelude2.visible_ratio = animation_progress

		if animation_progress >= 1.0:
			animation_finished = true
	else:
		if current_animation == 2:
			# Fade to black after the second animation finishes
			fade_rect.color.a += delta / fade_duration
			if fade_rect.color.a >= 1.0:
				fade_rect.color.a = 1.0  # Clamp the value to 1.0
				get_tree().change_scene_to_file("res://scenes/Sc1_Lvl1.1_Alchemy.tscn")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if animation_finished:
			if current_animation == 1:
				# Hide prelude1 and start animation for prelude2
				prelude1.visible = false
				prelude2.visible = true
				current_animation = 2
				start_animation(prelude2)
			else:
				# Both animations are finished, start the fade to black
				animation_finished = true
		else:
			# Skip the current animation instantly
			animation_progress = 1.0

func start_animation(label):
	animation_progress = 0.0
	animation_finished = false
	label.visible_ratio = 0.0
