extends KinematicBody2D

var direction = Vector2.RIGHT
var velocity = Vector2.ZERO

onready var ledgeCheckRight = $LedgeCheckRight
onready var ledgeCheckLeft = $LedgeCheckLeft
onready var sprite = $AnimatedSprite

func _physics_process(delta):
	
	var foundWall = is_on_wall()
	var foundLedge = not ledgeCheckRight.is_colliding() or not ledgeCheckLeft.is_colliding()
	
	if foundWall or foundLedge:
		direction *= -1
	
	velocity = direction * 22
	move_and_slide(velocity, Vector2.UP)
	
	sprite.flip_h = direction.x > 0
