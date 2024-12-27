extends Area3D
class_name GravField

signal gravity_strength_changed(grav_field)

@export var _field_enabled = true :
	set(value):
		if not value:
			gravity_strength = 0
		_field_enabled = value

# gravity strength in g's
@export var gravity_strength : float = 1 :
	set(value):
		_field_enabled = (value == 0)
		gravity_strength = value
		gravity_strength_changed.emit(self)

func enabled():
	return _field_enabled
