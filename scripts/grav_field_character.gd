extends CharacterBody3D

var grav_field : GravField = null
var grav_field_basis : Basis = Basis.IDENTITY

@export var init_velocity = Vector3(0, 0, 0)
@export var init_angular_velocity = Vector3(0, 0, 0)
@export var speed : int = 5

@export var mouse_sens : Vector2 = Vector2(1, 1)

@onready var field_detector_scn = preload("res://field_detector.tscn")
@onready var fpp_camera = %FirstPersonCamera
@onready var tpp_camera = %ThirdPersonCamera


var persistant_velocity := Vector3(0,0,0)
var grav_velocity_component := Vector3(0, 0, 0)

var has_touched_floor := false
var on_grav_exit_camera_rotation := Vector3.ZERO

#region grav values
var current_grav_move_rate := Vector3.ZERO #m/s
var grav_move_acceleration := 30 #m/s/s
var grav_move_max := 5 #m/s
#endregion

#region ZG values
var current_zg_translation_rates : Vector3 = Vector3.ZERO #m/s

var current_zg_yaw_rate : float = 0 #deg/s
var zg_yaw_acceleration : float = 100 #deg/s/s
var zg_yaw_max : float = 120 # deg/s

var zg_lateral_acceleration : float = 3 #m/s/s
var zg_lateral_max : float = 8 #m/s

var zg_ud_acceleration : float = 3 #m/s/s
var zg_ud_max : float = 3 #m/s
#endregion

func _physics_process(delta):
	# take player input as normalised vector
	var movement_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var jump_pressed := Input.is_action_pressed("jump")
	var zg_yaw_input := Input.get_axis("yaw_ccw", "yaw_cw")
	var zg_ud_input := Input.get_axis("zero_g_up", "zero_g_down")
	
	
	
	if grav_field and grav_field.enabled(): # Gravity
		if is_on_floor():
			if !has_touched_floor:
				var temp_persistent = grav_field_basis.inverse() * persistant_velocity
				temp_persistent.y = 0
				persistant_velocity = grav_field_basis * temp_persistent
				has_touched_floor = true
			grav_velocity_component = Vector3.ZERO
			if jump_pressed:
				grav_velocity_component = Vector3(0, 4, 0)
			# only add movement on floor when in gravity
			current_grav_move_rate = current_grav_move_rate.move_toward( \
				(_input_to_grav_normal(basis * Vector3(movement_input.x, 0, movement_input.y))) * grav_move_max, \
				grav_move_acceleration * delta)
			persistant_velocity = persistant_velocity.move_toward(Vector3.ZERO, 0.5)
		else:
			grav_velocity_component.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * grav_field.gravity_strength * delta
		velocity = grav_field_basis * grav_velocity_component + current_grav_move_rate + persistant_velocity
		
		_align_body_with_gravfield()
	else: # No gravity
		_align_camera_with_body(delta)
		
		#region ZG movement calculations
		if(zg_yaw_input != 0):
			current_zg_yaw_rate = move_toward(current_zg_yaw_rate, -zg_yaw_input * zg_yaw_max, zg_yaw_acceleration * delta)
		else:
			current_zg_yaw_rate = move_toward(current_zg_yaw_rate, 0, zg_yaw_acceleration * delta)
		rotate(basis.z.normalized(), deg_to_rad(current_zg_yaw_rate * delta))
		
		persistant_velocity = persistant_velocity.move_toward(Vector3.ZERO, zg_lateral_acceleration * delta)
		var total_zg_input := Vector3(movement_input.x, -zg_ud_input, movement_input.y)
		
		current_zg_translation_rates = current_zg_translation_rates.move_toward( \
			basis * total_zg_input * zg_lateral_max, \
			zg_lateral_acceleration * delta)
		#endregion
		
		velocity = persistant_velocity  + current_zg_translation_rates

	# apply velocity
	move_and_slide()


func toggle_camera():
	fpp_camera.current = !fpp_camera.current
	


func _input_to_grav_normal(input: Vector3) -> Vector3:
	# rotate input vector to floor normal
	var cross = basis.y.cross(get_floor_normal())
	var angle = basis.y.angle_to(get_floor_normal())
	if cross.length() == 0:
		return input
	return input.rotated(cross.normalized(), angle)

func _align_body_with_gravfield():
	var rotation_diff = basis.y.cross(grav_field_basis.y)
	# line up y axes of character and grav field, then snap when within 0.03
	if rotation_diff.length() > 0.03:
		# rotation speed is proportional to difference
		rotate(rotation_diff.normalized(), rotation_diff.length() / 9)
	elif rotation_diff.length() != 0:
		rotate(rotation_diff.normalized(), basis.y.angle_to(grav_field_basis.y))


func _align_camera_with_body(delta):
	var rotation_diff = basis.y.cross(fpp_camera.global_transform.basis.y)
	if rotation_diff.length() == 0: 
		return
	rotate(rotation_diff.normalized(), min(rotation_diff.length(), 4 * delta))
	fpp_camera.rotation.x = rotate_toward(fpp_camera.rotation.x, 0, 4 * delta)


func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed("toggle_pov"):
		toggle_camera()

func _input(event):
	if event is InputEventMouseMotion:
		# spin player around their y axis when mouse move in x dir
		rotate(basis.y.normalized(), -deg_to_rad(event.relative.x) * 0.1 * mouse_sens.x)
		# if in gravity move camera up and down, otherwise rotate player up and down
		if grav_field and grav_field.gravity_strength != 0:
			fpp_camera.rotate_x(-deg_to_rad(event.relative.y) * 0.1 * mouse_sens.y)
		else:
			rotate(basis.x.normalized(), -deg_to_rad(event.relative.y) * 0.1 * mouse_sens.y)


func _ready():
	velocity = init_velocity
	# Create field detector, place at center of mass, attach signals
	var field_detector = field_detector_scn.instantiate()
	field_detector.current_field_updated.connect(_on_current_field_updated)
	add_child(field_detector)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_current_field_updated(grav_field : GravField):
	if !grav_field:
		persistant_velocity = velocity
		current_grav_move_rate = Vector3.ZERO
		grav_field_basis = Basis.IDENTITY
	else:
		persistant_velocity = velocity
		current_zg_translation_rates = Vector3.ZERO
		has_touched_floor = false
		grav_field_basis = grav_field.global_transform.basis
	up_direction = grav_field_basis.y
	self.grav_field = grav_field
	
