extends CharacterBody2D

@export var move_speed: float = 50.0
@export var mow_speed_multiplier: float = 0.60
@export var mower_offset: float = 12.0

var mower: Node
var is_mowing: bool = false
var mower_pos: Vector2


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
		
		if is_instance_valid(mower):
			if dir != Vector2.ZERO:
				mower.position = dir * mower_offset
				mower_pos = mower.global_position
	
	# Move player
	move_and_slide()

# Check if player starts mowing.
func CheckMowing():
	if Input.is_action_just_pressed("toggle_mow"):
		# If not mowing, equip the mower
		if not is_mowing:
			for body in $MowerRange.get_overlapping_bodies():
				if body.is_in_group("Mower"):
					mower = body
					mower.get_parent().remove_child(mower)
					self.add_child(mower)
					mower.global_position = self.global_position
					mower.get_node("CollisionShape2D").disabled = true
					is_mowing = true
		# If mowing, drop the mower
		else:
			if is_instance_valid(mower):
				remove_child(mower)
				get_node("/root").add_child(mower)
				mower.set_global_position(mower_pos)
				mower.get_node("CollisionShape2D").disabled = false
				mower = null
				is_mowing = false
