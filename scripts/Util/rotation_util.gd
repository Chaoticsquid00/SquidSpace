extends Node
class_name RotationUtil

static func rotate_toward(from : Vector3, to : Vector3, angle_increment : float) -> Vector3:
	var cross := from.cross(to)
	if cross.length() < angle_increment:
		return to
	return cross.rotated(cross.normalized(), angle_increment)
