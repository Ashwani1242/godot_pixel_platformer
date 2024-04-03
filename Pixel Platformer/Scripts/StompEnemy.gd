extends Node2D

enum{ HOVER, FALL, LAND, RISE}

var state = HOVER

onready var start_pos = global_position
onready var timer := $Timer
onready var raycast: = $RayCast2D
onready var sprite: = $AnimatedSprite
onready var particles: = $Particles2D

func _physics_process(delta):
	match state:
		HOVER: hover_state()
		FALL: fall_state(delta)
		LAND: land_state()
		RISE: rise_state(delta)
		
func hover_state():
	if timer.time_left == 0:
		state = FALL

func fall_state(delta):
	position.y += 100 * delta
	sprite.animation = "Fall"
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		position.y = collision_point.y
		state = LAND
		timer.start(1.0)
		particles.emitting = true
		
func land_state():
	if timer.time_left == 0:
		state = RISE

func rise_state(delta):
	position.y = move_toward(position.y, start_pos.y, 20 * delta)
	sprite.animation = "Rise"
	if position == start_pos:
		state = HOVER
		timer.start(0.6)
		
		
