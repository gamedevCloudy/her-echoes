extends Node
class_name WakeUpSequence

@export var fade_in_duration: float = 3.0

var fade_overlay: ColorRect
var player: Node3D

func _ready() -> void:
	# Start the wake up sequence immediately
	start_wake_up()

func start_wake_up():
	print("Starting wake up sequence...")
	
	# Get player and disable movement initially
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = false
	
	# Create fade overlay starting black
	create_fade_overlay()
	
	# Fade in from black
	await fade_from_black()
	
	# Enable player movement
	if player:
		player.can_move = true
	
	print("Wake up sequence complete")

func create_fade_overlay():
	# Create UI overlay for fade effect
	var canvas = CanvasLayer.new()
	get_tree().current_scene.add_child(canvas)
	
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color(0, 0, 0, 1.0)  # Start fully black
	fade_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(fade_overlay)

func fade_from_black():
	print("Fading in from black...")
	await get_tree().create_timer(0.5).timeout  # Brief pause in black
	
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, fade_in_duration)
	await tween.finished
	
	# Remove the overlay after fade
	fade_overlay.queue_free()