extends Node

const LOSE = preload("res://Sound Effects/lose.wav")
const JUMP = preload("res://Sound Effects/jump.wav")

onready var audioPlayers: = $AudioPlayers

func play_sound(sound):
	for audioStreamPlayer in audioPlayers.get_children():
		if not audioStreamPlayer.playing:
			audioStreamPlayer.stream = sound
			audioStreamPlayer.play()
			break
