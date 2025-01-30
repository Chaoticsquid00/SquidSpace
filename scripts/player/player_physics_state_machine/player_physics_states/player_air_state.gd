extends PlayerPhysicsState
class_name PlayerAirState

static var unique_id : String = "PlayerAirState"

func update(delta):
	pass


func physics_update(delta : float):
	player_character.align_body_with_gravfield()
	if player_character.is_on_floor():
		transition.emit(PlayerFloorState.unique_id)
		return
	
	var grav_accel = ProjectSettings.get_setting("physics/3d/default_gravity") * current_grav_field.gravity_strength
	var grav_accel_in_field_direction = current_grav_field.global_basis * Vector3(0, grav_accel, 0)
	player_character.player_velocity -= grav_accel_in_field_direction * delta
	
	#TODO Solve issue of player sliding down wall and velocity being incorrect at floor
	
	player_character.velocity = player_character.player_velocity + current_grav_field.get_parent_velocity()
	UISignalBus.player_velocity_changed.emit(player_character.velocity)

func input_event(event):
	if event is InputEventMouseMotion:
		player_character.rotate_around_y(event.relative.x)
		player_character.rotate_x_fpp_camera(event.relative.y)

func grav_field_updated(field : GravField):
	super(field)
	if !field:
		transition.emit(PlayerZeroGravState.unique_id)
