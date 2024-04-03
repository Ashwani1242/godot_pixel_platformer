extends Node2D

const PlayerScene = preload("res://assets/_scenes/Player.tscn")

var player_spawn_location = Vector2.ZERO

onready var camera: = $Camera2D
onready var player: = $Player 
onready var timer: = $Timer

func _ready():
	VisualServer.set_default_clear_color(Color.cornflower)
	player.connect_camera(camera)
	player_spawn_location = player.global_position
	Events.connect("player_died", self, "on_player_died")
	Events.connect("hit_checkpoint", self, "on_hit_checkpoint")
	
func on_player_died():
	timer.start(1.0)
	yield(timer, "timeout")
	var player = PlayerScene.instance()
	player.position = player_spawn_location
	add_child(player)
	player.connect_camera(camera)
func on_hit_checkpoint(checkpoint_pos):
	player_spawn_location = checkpoint_pos
	
