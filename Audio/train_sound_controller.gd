extends Node3D

@onready var train_passing_player = $TrainPassingSound
@onready var train_horn_player = $TrainHornSound

func _ready():
	# Start the train passing sound at the 20 second mark to skip the silence
	if train_passing_player:
		train_passing_player.play()
		train_passing_player.seek(20.0)

func play_horn():
	if train_horn_player and not train_horn_player.playing:
		train_horn_player.play()