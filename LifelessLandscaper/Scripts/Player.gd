extends CharacterBody2D

@export var move_speed: float = 50.0

func _physics_process(delta):
	velocity = Vector2(Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_up", "move_down")).normalized()
	
	velocity *= move_speed
	
	move_and_slide()
