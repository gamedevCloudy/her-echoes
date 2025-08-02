extends Node

# Export variables for configuration in editor
@export var breathing_interval_min: float = 8.0
@export var breathing_interval_max: float = 15.0
@export var hurt_grunt_interval_min: float = 12.0
@export var hurt_grunt_interval_max: float = 25.0
@export var hallucination_interval_min: float = 20.0
@export var hallucination_interval_max: float = 45.0
@export var whisper_distance_min: float = 8.0
@export var whisper_distance_max: float = 20.0
@export var step_interval: float = 0.6

# Timer variables
var breathing_timer: float = 0.0
var hurt_grunt_timer: float = 0.0
var hallucination_timer: float = 0.0
var next_breathing_time: float = 0.0
var next_hurt_grunt_time: float = 0.0
var next_hallucination_time: float = 0.0
var walking_step_timer: float = 0.0

# Audio players
var whisper_players: Array[AudioStreamPlayer3D] = []
var player_node: CharacterBody3D

func _ready() -> void:
	player_node = get_parent()
	
	# Initialize audio timers
	_reset_breathing_timer()
	_reset_hurt_grunt_timer()
	_reset_hallucination_timer()
	
	# Setup whisper players array
	whisper_players = [
		player_node.get_node("%WhisperPlayer1"),
		player_node.get_node("%WhisperPlayer2"),
		player_node.get_node("%WhisperPlayer3")
	]

func update_audio_system(delta: float, is_walking: bool, can_move: bool) -> void:
	# Update timers
	breathing_timer += delta
	hurt_grunt_timer += delta
	hallucination_timer += delta
	
	# Handle breathing sounds
	if breathing_timer >= next_breathing_time:
		_play_breathing_sound()
		_reset_breathing_timer()
	
	# Handle hurt grunt sounds
	if hurt_grunt_timer >= next_hurt_grunt_time:
		_play_hurt_grunt_sound()
		_reset_hurt_grunt_timer()
	
	# Handle hallucination whispers
	if hallucination_timer >= next_hallucination_time:
		_play_hallucination_whisper()
		_reset_hallucination_timer()
	
	# Handle walking sounds
	if is_walking and can_move:
		walking_step_timer += delta
		if walking_step_timer >= step_interval:
			_play_walking_sound()
			walking_step_timer = 0.0
	else:
		walking_step_timer = 0.0
		# Stop walking sound when not moving
		var walking_player = player_node.get_node("%WalkingPlayer")
		if walking_player and walking_player.playing:
			walking_player.stop()

# Basic sound functions
func _play_breathing_sound() -> void:
	var breathing_player = player_node.get_node("%BreathingPlayer")
	if breathing_player and not breathing_player.playing:
		breathing_player.play()
		# Add audio duration to next breathing time to prevent overlap
		if breathing_player.stream:
			var audio_duration = breathing_player.stream.get_length()
			next_breathing_time += audio_duration

func _play_hurt_grunt_sound() -> void:
	var hurt_grunt_player = player_node.get_node("%HurtGruntPlayer")
	if hurt_grunt_player and not hurt_grunt_player.playing:
		hurt_grunt_player.play()
		# Add audio duration to next hurt grunt time to prevent overlap
		if hurt_grunt_player.stream:
			var audio_duration = hurt_grunt_player.stream.get_length()
			next_hurt_grunt_time += audio_duration

func _play_walking_sound() -> void:
	var walking_player = player_node.get_node("%WalkingPlayer")
	if walking_player and not walking_player.playing:
		walking_player.play()

func play_scream_effect() -> void:
	var scream_player = player_node.get_node("%ScreamPlayer")
	if scream_player:
		scream_player.play()

# Timer reset functions
func _reset_breathing_timer() -> void:
	breathing_timer = 0.0
	next_breathing_time = randf_range(breathing_interval_min, breathing_interval_max)

func _reset_hurt_grunt_timer() -> void:
	hurt_grunt_timer = 0.0
	next_hurt_grunt_time = randf_range(hurt_grunt_interval_min, hurt_grunt_interval_max)

func _reset_hallucination_timer() -> void:
	hallucination_timer = 0.0
	next_hallucination_time = randf_range(hallucination_interval_min, hallucination_interval_max)

# Hallucination system functions
func _play_hallucination_whisper() -> void:
	# Find an available whisper player
	var available_player: AudioStreamPlayer3D = null
	for player in whisper_players:
		if player and not player.playing:
			available_player = player
			break
	
	if available_player:
		# Position the player randomly around the character
		_position_whisper_player_randomly(available_player)
		available_player.play()
		# Trigger fear shake when whisper plays
		player_node.trigger_fear_shake()
		# Add audio duration to next hallucination time to prevent overlap
		if available_player.stream:
			var audio_duration = available_player.stream.get_length()
			next_hallucination_time += audio_duration

func _position_whisper_player_randomly(player: AudioStreamPlayer3D) -> void:
	# Generate random position around the player
	var angle = randf() * TAU  # Random angle in radians (0 to 2π)
	var distance = randf_range(whisper_distance_min, whisper_distance_max)
	
	# Calculate position relative to player
	var offset = Vector3(
		cos(angle) * distance,
		randf_range(-2.0, 3.0),  # Random height variation
		sin(angle) * distance
	)
	
	# Set the position relative to the player
	player.global_position = player_node.global_position + offset

func trigger_hallucination() -> void:
	_play_hallucination_whisper()