extends Node
class_name StateMachine

@export var initial_state : State

var states : Dictionary = {}
var current_state : State
var paused : bool = false

func _ready():
	for child in get_children():
		if child is State:
			child.transition.connect(_on_state_transition)
			print(child.unique_id)
			states[child.unique_id] = child
	print(states)
	
	if initial_state:
		initial_state.on_enter()
		current_state = initial_state


func _process(delta):
	if paused:
		return
	if current_state:
		current_state.update(delta)


func _on_state_transition(state_string : String):
	var new_state = states[state_string]
	if !new_state:
		push_error("state not found: ", state_string)
		return
	new_state.on_enter()
	current_state = new_state
	print("current state changed to: ", state_string)
