extends RigidBody3D
class_name GravFieldRigidBody3D

var gravity_strength : float = 0
var grav_field_basis : Basis = Basis.IDENTITY
var grav_field : GravField = null

## m/s/s
var linear_damp_zg : float = 0.3
## Between 0 and 1
var linear_friction : float = 1
## rad/s/s
var angular_damp_zg : float = 0.5
## Between 0 and 1
var angular_friction : float = 0.1

var is_on_floor := false
var is_on_cieling := false
var is_on_wall := false

@onready var field_detector_scn = preload("res://scenes/field_detector.tscn")

var grav_velocity = Vector3.ZERO

func _integrate_forces(state):
	var velocity = state.linear_velocity
	var changed_grav = grav_field_basis.y * state.get_total_gravity().length() * -gravity_strength
	
	var is_on_floor = false
	var is_on_ceiling = false
	var is_on_wall = false
	
	var i := 0
	while i < state.get_contact_count():
		var normal : Vector3 = state.get_contact_local_normal(i)
		is_on_floor = normal.dot(grav_field_basis.y) > 0.9
		is_on_cieling = normal.dot(grav_field_basis.y) < -0.9
		is_on_wall = abs(normal.dot(grav_field_basis.y)) < 0.9
		i += 1
	
	
	if(grav_field):
		grav_velocity += changed_grav * state.step
		if (is_on_floor):
			grav_velocity = Vector3.ZERO
		print(is_on_floor)
		velocity = velocity.move_toward(grav_field.get_parent().velocity, linear_friction * state.step) + grav_velocity * state.step
	else:
		grav_velocity = Vector3.ZERO
		velocity = velocity.move_toward(Vector3(0,0,0), linear_damp_zg * state.step)
		angular_velocity = angular_velocity.move_toward(Vector3(0,0,0), angular_damp_zg * state.step)
	
	
	# set rigidbody linear velocity to new calculated velocity
	state.linear_velocity = velocity

func _ready():
	# Create field detector, place at center of mass, attach signals
	var field_detector = field_detector_scn.instantiate()
	field_detector.current_field_updated.connect(_on_current_field_updated)
	add_child(field_detector)
	set_use_custom_integrator(true)

func _on_current_field_updated(_grav_field : GravField):
	self.grav_field = _grav_field
	if !grav_field:
		grav_field_basis = Basis.IDENTITY
		gravity_strength = 0
	else:
		grav_field_basis = grav_field.global_transform.basis
		gravity_strength = grav_field.gravity_strength
