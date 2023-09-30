extends CharacterBody2D

@export var move_speed: float = 50.0
@export var mow_speed_multiplier: float = 0.75
@export var mower_offset: float = 12.0

var is_mowing: bool = true

@onready var mower_object = $ExampleMesh

# Called every frame
func _process(delta):
	CheckMowing()

# Called every second
func _physics_process(delta):
	# Get movement vector
	var dir = Vector2(Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_up", "move_down")).normalized()
	
	# Multiply by speed
	velocity = dir * move_speed
	
	# Change speed if mowing
	if is_mowing:
		velocity *= mow_speed_multiplier
		if is_instance_valid(mower_object):
			mower_object.position = dir * mower_offset
	
	# Move player
	move_and_slide()

# Check if player starts mowing.
func CheckMowing():
	if Input.is_action_just_pressed("toggle_mow"):
		is_mowing = not is_mowing
	
	if is_mowing == false:
		if is_instance_valid(mower_object):
			remove_child(mower_object)
			get_node("/root").add_child(mower_object)
