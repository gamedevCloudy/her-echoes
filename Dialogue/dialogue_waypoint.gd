extends Area3D
class_name DialogueWaypoint

@export var dialogue_name: String = ""
@export var is_triggered: bool = false
@export var trigger_once: bool = true

signal dialogue_triggered(dialogue_name: String)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not is_triggered:
		is_triggered = true
		dialogue_triggered.emit(dialogue_name)
		print("Triggered dialogue: " + dialogue_name)
		
		if trigger_once:
			# Disable the area but keep it for potential re-enabling
			monitoring = false
