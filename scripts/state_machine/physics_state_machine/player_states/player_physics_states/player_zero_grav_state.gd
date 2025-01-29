extends PlayerPhysicsState
class_name PlayerZeroGravState

signal align_camera_with_body(delta : float)

var movement_input : Vector2
var yaw_input : float
var up_down_input : float

var current_yaw_rate : float = 0 #deg/s
@export var yaw_acceleration : float = 100 #deg/s/s
@export var yaw_max : float = 120 # deg/s

@export var lateral_acceleration : float = 3 #m/s/s
@export var lateral_max : float = 5 #m/s

static var unique_id : String = "PlayerZeroGravState"


func update(delta):
	pass


func physics_update(delta : float):
	_handle_inputs()
	player_character.align_camera_with_body(delta)
	
	if(yaw_input != 0):
		current_yaw_rate = move_toward(current_yaw_rate, -yaw_input * yaw_max, yaw_acceleration * delta)
	else:
		current_yaw_rate = move_toward(current_yaw_rate, 0, yaw_acceleration * delta)
	player_character.rotate(player_character.basis.z.normalized(), deg_to_rad(current_yaw_rate * delta))
	
	var total_input := Vector3(movement_input.x, -up_down_input, movement_input.y)
	
	player_character.velocity = player_character.velocity.move_toward( \
		player_character.basis * total_input * lateral_max, \
		lateral_acceleration * delta)


func _handle_inputs():
	movement_input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	yaw_input = Input.get_axis("yaw_ccw", "yaw_cw")
	up_down_input = Input.get_axis("zero_g_up", "zero_g_down")

func _input(event):
	if event is InputEventMouseMotion:
		player_character.rotate_around_y(event.relative.x)
		player_character.rotate_x_player(event.relative.y)

func grav_field_updated(field : GravField):
	super(field)
	if field:
		transition.emit(PlayerAirState.unique_id)
