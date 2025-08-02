extends Node3D
class_name NavWaypointGuide

@export var guide_material: StandardMaterial3D
@export var pulse_speed: float = 1.5
@export var pulse_intensity: float = 0.4
@export var base_brightness: float = 0.5

var mesh_instance: MeshInstance3D
var time: float = 0.0

func _ready() -> void:
	# Create sphere mesh
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 3.0
	sphere_mesh.radial_segments = 12
	sphere_mesh.rings = 8
	
	# Create mesh instance
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = sphere_mesh
	add_child(mesh_instance)
	
	# Create white navigation material
	if not guide_material:
		guide_material = StandardMaterial3D.new()
		guide_material.albedo_color = Color(0.9, 0.9, 1.0, 0.6)  # Pale white-blue
		guide_material.emission_enabled = true
		guide_material.emission = Color(0.8, 0.8, 1.0)  # White glow
		guide_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		guide_material.no_depth_test = true  # Show through objects
		guide_material.flags_unshaded = true
		guide_material.grow_amount = 0.05  # Subtle outer glow
		guide_material.rim_enabled = true
		guide_material.rim = 0.4
		guide_material.rim_tint = 0.3
	
	mesh_instance.material_override = guide_material

func _process(delta: float) -> void:
	time += delta
	
	# Gentle pulsing effect (less intense than dialogue waypoints)
	var pulse = (sin(time * pulse_speed) + 1.0) * 0.5
	var current_intensity = base_brightness + (pulse * pulse_intensity)
	
	if guide_material:
		guide_material.emission = Color(current_intensity * 0.8, current_intensity * 0.8, current_intensity)
		guide_material.albedo_color.a = 0.4 + (pulse * 0.2)
		guide_material.rim = 0.3 + (pulse * 0.2)
	
	# Subtle floating motion
	position.y += sin(time * 1.2) * 0.008

func show_guide() -> void:
	visible = true

func hide_guide() -> void:
	visible = false