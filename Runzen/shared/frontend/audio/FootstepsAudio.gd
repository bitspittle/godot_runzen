extends Node

var _footstep_sounds = [
	load("res://shared/frontend/assets/sounds/step_grass_1.wav"),
	load("res://shared/frontend/assets/sounds/step_grass_2.wav"),
	load("res://shared/frontend/assets/sounds/step_grass_3.wav"),
	load("res://shared/frontend/assets/sounds/step_grass_4.wav")
]

const _NUM_AUDIO_PLAYERS = 6
var _audio_players = []
var _next_player_index = 0

func _ready():
	for i in _NUM_AUDIO_PLAYERS:
		var player = AudioStreamPlayer.new()
		add_child(player)
		_audio_players.append(player)

func step():
	var next_player = _audio_players[_next_player_index]
	_next_player_index = (_next_player_index + 1) % _NUM_AUDIO_PLAYERS

	next_player.stream = _footstep_sounds[randi() % _footstep_sounds.size()]
	# Slightly randomize pitch so even if we choose the same step sounds
	# twice in a row, it still sounds a little different
	next_player.pitch_scale = rand_range(0.9, 1.1)
	next_player.play()
