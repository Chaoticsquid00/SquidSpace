extends PlayerPhysicsState
class_name PlayerFloorState

@export var move_acceleration := 30 #m/s/s
@export var move_max := 5 #m/s

@export var jump_velocity := 5 #m/s

var movement_input : Vector2
var jump_pressed : bool

static var unique_id : String = "PlayerFloorState"

func update(delta):
	pass

func physics_update(delta : float):
	_handle_inputs()
	player_character.align_body_with_gravfield()
	
	if !player_character.is_on_floor():
		transition.emit(PlayerAirState.unique_id)
		return
	
	# constant -1 y velocity to keep player on ground
	var move_input_in_grav_basis := player_character.global_basis * Vector3(movement_input.x, -0.2, movement_input.y)
	# move velocity toward movement input
	player_character.player_velocity = player_character.player_velocity.move_toward(\
		_input_to_floor_normal(\
			move_input_in_grav_basis, \
			current_grav_field.global_basis.y, \
			player_character.get_floor_normal()) * move_max, \
		move_acceleration * delta)
	
	
	# when jump pressed add a basis-oriented y impulse (plus remove the 1m/s that keeps the player grounded)
	if jump_pressed:
		player_character.player_velocity += current_grav_field.global_basis * Vector3(0, jump_velocity + 1, 0)
	
	player_character.velocity = player_character.player_velocity + current_grav_field.get_parent_velocity()
	UISignalBus.player_velocity_changed.emit(player_character.velocity)


func _handle_inputs():
	movement_input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	jump_pressed = Input.is_action_pressed("jump")

func input_event(event):
	if event is InputEventMouseMotion:
		player_character.rotate_around_y(event.relative.x)
		player_character.rotate_x_fpp_camera(event.relative.y)

func grav_field_updated(field : GravField):
	super(field)
	if !field:
		transition.emit(PlayerZeroGravState.unique_id)
