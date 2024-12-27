extends RigidBody3D
class_name GravFieldRigidBody3D

var gravity_strength : float = 0
var grav_field_basis : Basis = Basis.IDENTITY

@onready var field_detector_scn = preload("res://field_detector.tscn")

func _integrate_forces(state):
	var dt = state.get_step()
	var velocity = state.get_linear_velocity()
	var changed_grav = grav_field_basis.y * state.get_total_gravity().length() * - gravity_strength
	
	state.set_linear_velocity(velocity + changed_grav * dt)

func _ready():
	# Create field detector, place at center of mass, attach signals
	var field_detector = field_detector_scn.instantiate()
	field_detector.current_field_updated.connect(_on_current_field_updated)
	add_child(field_detector)
	set_use_custom_integrator(true)

func _on_current_field_updated(grav_field):
	if grav_field == null:
		grav_field_basis = Basis.IDENTITY
		gravity_strength = 0
		return
	grav_field_basis = grav_field.global_transform.basis
	gravity_strength = grav_field.gravity_strength
