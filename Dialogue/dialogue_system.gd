extends Node
class_name DialogueSystem

@export var static_audio: AudioStream
@export var static_delay: float = 1.5

var dialogue_audio_files: Dictionary = {}
var static_player: AudioStreamPlayer
var dialogue_player: AudioStreamPlayer
var is_playing: bool = false

func _ready() -> void:
	# Create audio players
	static_player = AudioStreamPlayer.new()
	dialogue_player = AudioStreamPlayer.new()
	add_child(static_player)
	add_child(dialogue_player)
	
	# Load static audio
	if static_audio:
		static_player.stream = static_audio
	
	# Load dialogue audio files
	load_dialogue_files()

func load_dialogue_files() -> void:
	var dialogue_dir = "res://Dialogue/"
	var dir = DirAccess.open(dialogue_dir)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".wav") and file_name != "radio_static.wav":
				var dialogue_name = file_name.replace(".wav", "")
				var audio_stream = load(dialogue_dir + file_name)
				dialogue_audio_files[dialogue_name] = audio_stream
				print("Loaded dialogue: " + dialogue_name)
			file_name = dir.get_next()

func play_dialogue(dialogue_name: String) -> void:
	if is_playing:
		return
		
	if not dialogue_audio_files.has(dialogue_name):
		print("Dialogue not found: " + dialogue_name)
		return
	
	is_playing = true
	
	# Play static first
	if static_player.stream:
		static_player.play()
		await get_tree().create_timer(static_delay).timeout
	
	# Play dialogue
	dialogue_player.stream = dialogue_audio_files[dialogue_name]
	dialogue_player.play()
	
	# Wait for dialogue to finish
	await dialogue_player.finished
	is_playing = false

func stop_all_audio() -> void:
	static_player.stop()
	dialogue_player.stop()
	is_playing = false