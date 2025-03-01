extends PhysicsStateMachine
class_name PlayerPhysicsStateMachine


func grav_field_updated(field : GravField):
	current_state.grav_field_updated(field)


func set_player(player : Player):
	for state in states.values():
		state.player_character = player
