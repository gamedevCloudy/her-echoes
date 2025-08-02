extends CharacterBody3D

@export var speed=8
@export var jump_vel=15
@export var gravity=30
var can_move: bool = true
var inventory: Array[String] = []

# Head sway variables
@export var head_sway_intensity: float = 0.05
@export var head_sway_speed: float = 10.0
@export var head_sway_rotation_intensity: float = 15.0
var head_sway_time: float = 0.0
var original_camera_position: Vector3
var original_camera_rotation: Vector3

# Fear shake variables
@export var fear_shake_intensity: float = 0.3
@export var fear_shake_duration: float = 1.2
@export var fear_shake_delay: float = 0.4
var fear_shake_timer: float = 0.0
var fear_shake_delay_timer: float = 0.0
var is_fear_shaking: bool = false
var is_waiting_for_shake: bool = false

var is_walking: bool = false

signal item_collected(item_name: String)

func _ready() -> void:
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	original_camera_position = %Camera3D.position
	original_camera_rotation = %Camera3D.rotation_degrees

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: 
		rotation_degrees.y -= event.relative.x * 0.5
		%Camera3D.rotation_degrees.x -= event.relative.y * 0.5
		
		#limit the roation 
		%Camera3D.rotation_degrees.x = clamp(
			%Camera3D.rotation_degrees.x, -60.0, 65.0
		)
	elif event.is_action_pressed("ui_cancel"): 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta: float) -> void:
	
#	Ground movement
	var input_dir_2D = Input.get_vector(
		"move_left", "move_right", "move_fwd", "move_back"
	)
	
	var input_dir_3d = Vector3(
		input_dir_2D.x, 0.0, input_dir_2D.y
	)
	
	var movement_dir = transform.basis * input_dir_3d
	var is_moving = input_dir_2D.length() > 0.1 and is_on_floor()
	
	# Update walking state
	is_walking = is_moving
	
	if can_move: 
		velocity.x = movement_dir.x * speed
		velocity.z = movement_dir.z * speed
		
		# Apply gravity
		if not is_on_floor():
			velocity.y -= gravity * delta
		
		# Jumping 
		if Input.is_action_just_pressed("jump") and is_on_floor(): 
			velocity.y = jump_vel
		
	# Handle fear shake delay and execution
	var final_position_offset = Vector3.ZERO
	var final_rotation_offset = Vector3.ZERO
	
	# Handle delay before shake starts
	if is_waiting_for_shake:
		fear_shake_delay_timer += delta
		if fear_shake_delay_timer >= fear_shake_delay:
			is_waiting_for_shake = false
			is_fear_shaking = true
			fear_shake_delay_timer = 0.0
			fear_shake_timer = 0.0
	
	# Handle the actual fear shake
	if is_fear_shaking:
		fear_shake_timer += delta
		if fear_shake_timer >= fear_shake_duration:
			is_fear_shaking = false
			fear_shake_timer = 0.0
		else:
			# Violent, erratic shake that mimics jump scare reaction
			var shake_progress = fear_shake_timer / fear_shake_duration
			var shake_falloff = 1.0 - shake_progress  # Reduce intensity over time
			
			final_position_offset += Vector3(
				(randf() - 0.5) * fear_shake_intensity * shake_falloff,
				(randf() - 0.5) * fear_shake_intensity * shake_falloff * 0.7,
				(randf() - 0.5) * fear_shake_intensity * shake_falloff * 0.3
			)
			
			final_rotation_offset += Vector3(
				(randf() - 0.5) * fear_shake_intensity * shake_falloff * 8.0,  # Pitch jitter
				(randf() - 0.5) * fear_shake_intensity * shake_falloff * 12.0, # Yaw jitter
				(randf() - 0.5) * fear_shake_intensity * shake_falloff * 15.0  # Roll jitter
			)
	
	# Head sway when walking
	if is_moving and can_move:
		head_sway_time += delta * head_sway_speed
		var sway_offset = Vector3(
			sin(head_sway_time) * head_sway_intensity,
			sin(head_sway_time * 2.0) * head_sway_intensity * 0.5,
			0.0
		)
		var sway_rotation = Vector3(
			0.0,
			0.0,
			sin(head_sway_time * 0.7) * head_sway_intensity * head_sway_rotation_intensity  # Roll rotation for retro feel
		)
		%Camera3D.position = original_camera_position + sway_offset + final_position_offset
		%Camera3D.rotation_degrees = Vector3(
			%Camera3D.rotation_degrees.x + final_rotation_offset.x,  # Keep mouse look pitch + fear shake
			original_camera_rotation.y + final_rotation_offset.y,   # Reset yaw to original + fear shake
			original_camera_rotation.z + sway_rotation.z + final_rotation_offset.z  # Add roll sway + fear shake
		)
	else:
		# Smoothly return to original position and rotation when not moving
		var target_position = original_camera_position + final_position_offset
		var target_rotation_z = original_camera_rotation.z + final_rotation_offset.z
		%Camera3D.position = %Camera3D.position.lerp(target_position, delta * 5.0)
		%Camera3D.rotation_degrees.z = lerp(%Camera3D.rotation_degrees.z, target_rotation_z, delta * 5.0)
		
		# Apply fear shake rotation even when not moving
		if is_fear_shaking:
			%Camera3D.rotation_degrees.x += final_rotation_offset.x
			%Camera3D.rotation_degrees.y += final_rotation_offset.y
		
	if position.y < -20: 
		can_move = false
		position = Vector3.UP; 
		enable_movement(2)
	
	# Handle audio updates
	%SoundSystem.update_audio_system(delta, is_walking, can_move)
	
	move_and_slide()

func enable_movement(duration: float): 
	await get_tree().create_timer(duration).timeout
	can_move = true

func add_item_to_inventory(item) -> void:
	var item_name: String
	if item is Item:
		item_name = item.item_name
	else:
		item_name = str(item)
	
	inventory.append(item_name)
	item_collected.emit(item_name)
	print("Collected: " + item_name + " | Inventory: " + str(inventory))

func has_item(item_name: String) -> bool:
	return item_name in inventory

func get_inventory() -> Array[String]:
	return inventory

# Sound system wrapper functions for external access
func play_scream_effect() -> void:
	%SoundSystem.play_scream_effect()

func trigger_hallucination() -> void:
	%SoundSystem.trigger_hallucination()

func trigger_fear_shake() -> void:
	is_waiting_for_shake = true
	fear_shake_delay_timer = 0.0
