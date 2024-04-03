tool
extends Path2D

enum Animation_Type{ LOOP, BOUNCE}
export (Animation_Type) var animationType setget set_animation_type

onready var animationPlayer: = $AnimationPlayer 

func set_animation_type(value):
	animationType = value
	var ap = find_node("AnimationPlayer")
	if ap: play_updated_animation(ap)

func _ready():
	play_updated_animation(animationPlayer)
	
func play_updated_animation(ap):
	match animationType:
		Animation_Type.BOUNCE : ap.play("MoveAlongPathBOUNCE")
		Animation_Type.LOOP: ap.play("MoveAlongPathLOOP")
