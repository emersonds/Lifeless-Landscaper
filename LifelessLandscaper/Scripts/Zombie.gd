extends StaticBody2D

@export var time_before_hide: float = 1.0
@export var time_before_alert: float = 5.0

var is_hidden: bool	# Used for hiding and revealing zombie
var hiding: bool	# Used for animation_finished check
var is_on_alert: bool

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hitbox: CollisionShape2D = $Hitbox
@onready var hide_timer: Timer = $HideTimer
@onready var alert_timer: Timer = $AlertTimer

func _ready():
	_hide_zombie()
	is_on_alert = true
	hide_timer.wait_time = time_before_hide
	alert_timer.wait_time = time_before_alert


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		if is_hidden and is_on_alert:
			_reveal_zombie()

func _hide_zombie():
	sprite.visible = false
	hitbox.set_deferred("disabled", true)
	
	is_hidden = true

func _reveal_zombie():
	# Change collision layer to allow collisions
	hitbox.set_deferred("disabled", false)
	sprite.visible = true
	sprite.play("zombie_rise")
	
	is_on_alert = false
	is_hidden = false
	hide_timer.start()


func _on_hide_timer_timeout():
	hiding = true
	sprite.play_backwards("zombie_rise")


func _on_alert_timer_timeout():
	is_on_alert = true


func _on_sprite_animation_finished():
	if hiding:
		_hide_zombie()
		hiding = false
		alert_timer.start()
