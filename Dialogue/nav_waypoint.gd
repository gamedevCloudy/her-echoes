extends Area3D
class_name NavWaypoint

@export var is_triggered: bool = false
@export var trigger_once: bool = true

signal nav_waypoint_triggered()

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not is_triggered:
		is_triggered = true
		nav_waypoint_triggered.emit()
		print("Triggered navigation waypoint")
		
		if trigger_once:
			monitoring = false
