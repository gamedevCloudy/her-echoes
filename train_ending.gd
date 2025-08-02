extends Node3D
class_name TrainEnding

@export var train_camera_position: Vector3 = Vector3(150, 15, 49)  # Position on departing train looking back at tower
@export var fade_speed: float = 1.5

var player: Node3D
var original_camera: Camera3D
var ending_camera: Camera3D
var fade_overlay: ColorRect

func start_train_ending():
	print("Starting train ending sequence...")
	
	# Get player and disable movement
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = false
		original_camera = player.get_node("%Camera3D")
	
	# Make train visible for the ending
	var train = get_tree().current_scene.get_node("StoryElements/TrainArea/IncomingTrain")
	if train:
		train.visible = true
	
	# Create ending camera on train
	ending_camera = Camera3D.new()
	add_child(ending_camera)
	ending_camera.global_position = train_camera_position
	ending_camera.look_at(Vector3(55, 20, 63), Vector3.UP)  # Look at tower
	ending_camera.current = true
	
	# Create fade overlay
	create_fade_overlay()
	
	# Play final dialogue
	var dialogue_system = get_tree().current_scene.get_node("DialogueSystem")
	if dialogue_system:
		dialogue_system.play_dialogue("radio_reveal")
		# Wait for dialogue to finish, then fade out
		await dialogue_system.dialogue_player.finished
		fade_to_black()
	else:
		# Fallback if no dialogue system
		await get_tree().create_timer(5.0).timeout
		fade_to_black()

func create_fade_overlay():
	# Create UI overlay for fade effect
	var canvas = CanvasLayer.new()
	add_child(canvas)
	
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color(0, 0, 0, 0)  # Start transparent
	fade_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(fade_overlay)

func fade_to_black():
	print("Fading to black...")
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, fade_speed)
	await tween.finished
	
	# Wait a moment in black, then quit
	await get_tree().create_timer(2.0).timeout
	print("Game Complete - Ending")
	get_tree().quit()