extends PhysicsState
class_name PlayerPhysicsState

static var current_grav_field : GravField

# set from parent
var player_character : GravFieldPlayer


func grav_field_updated(field : GravField):
	current_grav_field = field


func _input_to_floor_normal(input: Vector3, up_direction : Vector3, floor_normal : Vector3) -> Vector3:
	# rotate input vector to floor normal
	var cross = up_direction.cross(floor_normal)
	var angle = up_direction.angle_to(floor_normal)
	if cross.length() == 0:
		return input
	return input.rotated(cross.normalized(), angle)
