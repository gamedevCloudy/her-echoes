extends Node3D
class_name WaypointGuide

@export var guide_material: StandardMaterial3D
@export var pulse_speed: float = 2.0
@export var pulse_intensity: float = 0.8
@export var base_brightness: float = 0.3

var mesh_instance: MeshInstance3D
var time: float = 0.0

func _ready() -> void:
	# Create sphere mesh
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 5.0
	sphere_mesh.radial_segments = 16
	sphere_mesh.rings = 12
	
	# Create mesh instance
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = sphere_mesh
	add_child(mesh_instance)
	
	# Create horror-themed material
	if not guide_material:
		guide_material = StandardMaterial3D.new()
		guide_material.albedo_color = Color(0.8, 0.1, 0.1, 0.8)  # Dark red
		guide_material.emission_enabled = true
		guide_material.emission = Color(1.5, 0.2, 0.2)  # Brighter red glow
		guide_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		guide_material.no_depth_test = true  # Show through objects
		guide_material.flags_unshaded = true
		guide_material.grow_amount = 0.1  # Adds outer glow effect
		guide_material.rim_enabled = true
		guide_material.rim = 0.8
		guide_material.rim_tint = 0.5
	
	mesh_instance.material_override = guide_material

func _process(delta: float) -> void:
	time += delta
	
	# Pulsing effect
	var pulse = (sin(time * pulse_speed) + 1.0) * 0.5
	var current_intensity = base_brightness + (pulse * pulse_intensity)
	
	if guide_material:
		guide_material.emission = Color(current_intensity * 1.5, current_intensity * 0.2, current_intensity * 0.2)
		guide_material.albedo_color.a = 0.6 + (pulse * 0.4)
		guide_material.rim = 0.6 + (pulse * 0.4)
	
	# Subtle floating motion
	position.y += sin(time * 1.5) * 0.01

func show_guide() -> void:
	visible = true

func hide_guide() -> void:
	visible = false