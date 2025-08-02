extends Node3D

@onready var dialogue_system = $DialogueSystem
@onready var dialogue_waypoints = $DialogueWaypoints
@onready var nav_waypoints = $NavWaypoints

var waypoint_order: Array[String] = [
	"WakeupWaypoint",
	"BlameWaypoint", 
	"TowerApproachWaypoint",
	"After Tower",
	"ReturnWaypoint",
	"TowerTopWaypoint"
]

var nav_waypoint_order: Array[String] = []  # Will be populated from scene

var current_waypoint_index: int = 0
var current_nav_index: int = 0
var waypoint_guides: Dictionary = {}
var nav_guides: Dictionary = {}

func _ready() -> void:
	# Start wake up sequence
	var wake_up = preload("res://wake_up_sequence.gd").new()
	add_child(wake_up)
	
	# Connect all dialogue waypoint signals
	for waypoint in dialogue_waypoints.get_children():
		if waypoint is DialogueWaypoint:
			waypoint.dialogue_triggered.connect(_on_dialogue_triggered)
			
			# Create red visual guide for dialogue waypoints
			var guide = preload("res://Dialogue/waypoint_guide.tscn").instantiate()
			guide.position = waypoint.position + Vector3(0, 8, 0)  # Float above waypoint
			guide.scale = Vector3(1, 1, 1)  # Ensure uniform scaling
			add_child(guide)
			waypoint_guides[waypoint.name] = guide
			guide.hide_guide()  # Hide all initially
	
	# Connect navigation waypoints if they exist
	if nav_waypoints:
		for nav_waypoint in nav_waypoints.get_children():
			if nav_waypoint is NavWaypoint:
				nav_waypoint.nav_waypoint_triggered.connect(_on_nav_waypoint_triggered)
				nav_waypoint_order.append(nav_waypoint.name)
				
				# Create white visual guide for nav waypoints
				var nav_guide = preload("res://Dialogue/nav_waypoint_guide.tscn").instantiate()
				nav_guide.position = nav_waypoint.position + Vector3(0, 6, 0)
				nav_guide.scale = Vector3(1, 1, 1)  # Ensure uniform scaling
				add_child(nav_guide)
				nav_guides[nav_waypoint.name] = nav_guide
				nav_guide.hide_guide()  # Hide all initially
	
	# Show guide for first waypoint
	show_current_waypoint_guide()
	show_current_nav_guide()

func _on_dialogue_triggered(dialogue_name: String) -> void:
	dialogue_system.play_dialogue(dialogue_name)
	
	# Hide current guide and advance to next waypoint
	hide_current_waypoint_guide()
	current_waypoint_index += 1
	show_current_waypoint_guide()

func _on_nav_waypoint_triggered() -> void:
	# Hide current nav guide and advance to next
	hide_current_nav_guide()
	current_nav_index += 1
	show_current_nav_guide()

func show_current_waypoint_guide() -> void:
	if current_waypoint_index < waypoint_order.size():
		var waypoint_name = waypoint_order[current_waypoint_index]
		if waypoint_guides.has(waypoint_name):
			waypoint_guides[waypoint_name].show_guide()

func hide_current_waypoint_guide() -> void:
	if current_waypoint_index < waypoint_order.size():
		var waypoint_name = waypoint_order[current_waypoint_index]
		if waypoint_guides.has(waypoint_name):
			waypoint_guides[waypoint_name].hide_guide()

func show_current_nav_guide() -> void:
	if current_nav_index < nav_waypoint_order.size():
		var nav_name = nav_waypoint_order[current_nav_index]
		if nav_guides.has(nav_name):
			nav_guides[nav_name].show_guide()

func hide_current_nav_guide() -> void:
	if current_nav_index < nav_waypoint_order.size():
		var nav_name = nav_waypoint_order[current_nav_index]
		if nav_guides.has(nav_name):
			nav_guides[nav_name].hide_guide()