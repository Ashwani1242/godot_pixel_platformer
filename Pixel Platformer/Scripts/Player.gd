extends KinematicBody2D
class_name Player

enum{ MOVE, CLIMB }

export(Resource) var moveData = preload("res://Resources/DefaultPlayerMovementData.tres") as PlayerMovementData

var velocity = Vector2.ZERO
var state = MOVE
var jumpCount = 1
var bufferJump = false
var coyoteJump = false
var on_door = false
onready var ladderCheck: = $LadderCheck
onready var animatedSprite: = $AnimatedSprite
onready var jumpBufferTimer: = $JumpBufferTimer
onready var coyoteJumpTimer: = $CoyoteJumpTimer
onready var remoteTransform2D: = $RemoteTransform2D

func _ready():
	moveData = moveData as PlayerMovementData
	print("Hello World")

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	match state:
		MOVE: move_state(input, delta)
		CLIMB: climb_state(input)

func move_state(input, delta):
	
	if is_on_ladder() and (Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down")):
		state = CLIMB
	
	apply_gravity(delta)
	if input.x == 0:
		apply_friction(delta)
		animatedSprite.animation = "Idle"
	else:
		apply_acceleration(input.x, delta)
		animatedSprite.animation = "Run"
		
	if is_on_floor() or coyoteJump: 
		jumpCount = moveData.maxJumpCount
		input_jump()
		
	else:
		animatedSprite.animation = "Jump"
		input_jump_release()
		input_double_jump()
		input_buffer_jump()
		fast_fell_gravity(delta)
			
	if input.x > 0:
		animatedSprite.flip_h = input.x > 0
	elif input.x < 0:
		animatedSprite.flip_h = false
		
	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	var just_landed = is_on_floor() and was_in_air
	if just_landed:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
		
	var just_left_ground = not is_on_floor() and was_on_floor
	if just_left_ground and velocity.y >= 0:
		coyoteJump = true
		coyoteJumpTimer.start()
	
func climb_state(input):
	if not is_on_ladder():
		state = MOVE
	
	velocity = input * moveData.climbSpeed
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if velocity.length() == 0:
		animatedSprite.animation = "Idle"
	else:
		animatedSprite.animation = "Run"
		#animatedSprite.flip_h = direction.x > 0
	if input.x > 0:
		animatedSprite.flip_h = input.x > 0
	elif input.x < 0:
		animatedSprite.flip_h = false

func player_dead():
	SoundPlayer.play_sound(SoundPlayer.LOSE)
	queue_free()
	Events.emit_signal("player_died")

func is_on_ladder():
	if not ladderCheck.is_colliding(): return false
	var collider = ladderCheck.get_collider()
	if not collider is Ladder: return false
	return true

func apply_gravity(delta):
	velocity.y += moveData.gravity * delta
	velocity.y = min(velocity.y, 240)

func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, moveData.friction * delta)
	
func fast_fell_gravity(delta):
	if velocity.y > 0:
			velocity.y += moveData.fastFellGravity * delta
	
func apply_acceleration(amount, delta):
	velocity.x = move_toward(velocity.x, moveData.moveSpeed * amount, moveData.acceleration * delta)

func input_jump():
	if on_door: return
	if Input.is_action_just_pressed("ui_up") or bufferJump:
			SoundPlayer.play_sound(SoundPlayer.JUMP)
			velocity.y = moveData.jumpForce
			bufferJump = false
func input_double_jump():
	if Input.is_action_just_pressed("ui_up") and jumpCount > 1:
		SoundPlayer.play_sound(SoundPlayer.JUMP)
		velocity.y = moveData.jumpForce
		jumpCount -= 1
func input_jump_release():
	if Input.is_action_just_released("ui_up") and velocity.y < moveData.jumpRelease:
			velocity.y = moveData.jumpRelease
func input_buffer_jump():
	if Input.is_action_just_pressed("ui_up"):
			bufferJump = true
			jumpBufferTimer.start()

func _on_JumpBufferTimer_timeout():
	bufferJump = false
func _on_CoyoteJumpTimer_timeout():
	coyoteJump = false

func connect_camera(camera):
	var camera_path = camera.get_path()
	remoteTransform2D.remote_path = camera_path
	
