extends StateMachine
class_name PhysicsStateMachine


func _physics_process(delta):
	current_state.physics_update(delta)
