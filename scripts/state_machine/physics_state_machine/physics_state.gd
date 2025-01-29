extends State
class_name PhysicsState

func physics_update(delta : float):
	push_error("physics_update not overridden: ", get_script().get_global_name())
