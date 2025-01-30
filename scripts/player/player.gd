extends CharacterBody3D
class_name Player

var grav_field : GravField = null

@export var mouse_sens : Vector2 = Vector2(1, 1)

@onready var field_detector = %FieldDetector

@export var fpp_camera : Camera3D
@export var tpp_camera : Camera3D
@export var physics_state_machine : PlayerPhysicsStateMachine

var player_velocity = Vector3.ZERO
@onready var interial_force = 3

#region gd overrides

func _ready():
	# Create field detector, place at center of mass, attach signals
	field_detector.current_field_updated.connect(_on_current_field_updated)
	physics_state_machine.set_player(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed("toggle_pov"):
		toggle_camera()

func _physics_process(delta):
	# apply velocity calculated in physics state machine
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collided = get_slide_collision(i)
		if collided.get_collider() is RigidBody2D:
			collided.get_collider().apply_central_impulse(-collided.get_normal() * interial_force)

#endregion


#region helpers

func toggle_camera():
	fpp_camera.current = !fpp_camera.current

func align_body_with_gravfield():
	var rotation_diff = basis.y.cross(grav_field.global_basis.y)
	# line up y axes of character and grav field, then snap when within 0.03
	if rotation_diff.length() > 0.03:
		# rotation speed is proportional to difference
		rotate(rotation_diff.normalized(), rotation_diff.length() / 9)
	elif rotation_diff.length() != 0:
		rotate(rotation_diff.normalized(), basis.y.angle_to(grav_field.global_basis.y))

func rotate_around_y(value):
		rotate(basis.y.normalized(), -deg_to_rad(value) * 0.1 * mouse_sens.x)

func rotate_x_fpp_camera(value):
	fpp_camera.rotate_x(-deg_to_rad(value) * 0.1 * mouse_sens.y)

func rotate_x_player(value):
	rotate(basis.x.normalized(), -deg_to_rad(value) * 0.1 * mouse_sens.y)

func align_camera_with_body(delta):
	var rotation_diff = basis.y.cross(fpp_camera.global_transform.basis.y)
	if rotation_diff.length() < 0.03: 
		fpp_camera.rotation.x = 0
	else:
		rotate(rotation_diff.normalized(), min(rotation_diff.length(), 4 * delta))
		fpp_camera.rotation.x = rotate_toward(fpp_camera.rotation.x, 0, 4 * delta)

#endregion


#region signal handlers

func _on_current_field_updated(field : GravField):
	UISignalBus.grav_field_changed.emit(field)
	physics_state_machine.grav_field_updated(field)
	if field:
		up_direction = field.global_basis.y
	else:
		up_direction = Basis.IDENTITY.y
	self.grav_field = field

#endregion
