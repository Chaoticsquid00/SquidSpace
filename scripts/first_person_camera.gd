extends Camera3D

@export var flashlight : SpotLight3D
@export var direction_indicator : MeshInstance3D

func set_flashlight(enabled : bool):
	flashlight.visible = enabled

func toggle_flashlight():
	flashlight.visible = !flashlight.visible

func set_direction_indicator(enabled : bool):
	direction_indicator.visible = enabled

func toggle_direction_indicator():
	direction_indicator.visible = !direction_indicator.visible
