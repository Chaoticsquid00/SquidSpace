extends PlayerPhysicsState
class_name PlayerInteractingState

func update(delta):
	pass

func physics_update(delta : float, velocity : Vector3) -> Vector3:
	return Vector3.ZERO

func floored_updated(on_floor : bool):
	pass

func grav_field_updated(field : GravField):
	pass
