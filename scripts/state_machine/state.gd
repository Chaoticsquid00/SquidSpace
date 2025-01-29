extends Node
class_name State

signal transition(new_state : State)

func on_enter():
	pass


func on_exit():
	pass


func update(_delta):
	push_error("update not overridden: ", get_script().get_global_name())
