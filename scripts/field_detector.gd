extends Area3D
class_name FieldDetector

signal current_field_updated(current_field : GravField)

# field stack prioritises most recently entered field
var field_stack : Array = []
var current_field : GravField


func _ready():
	area_entered.connect(_on_area_enter)
	area_exited.connect(_on_area_exit)


func _on_area_enter(area : Area3D):
	print("Area entered")
	if area is GravField:
		field_stack.push_back(area)
		current_field = area
		current_field_updated.emit(current_field)


func _on_area_exit(area : Area3D):
	print("Area exited")
	if area is GravField:
		if area == current_field:
			field_stack.pop_back()
			current_field = field_stack.back() if field_stack.size() > 0 else null
			current_field_updated.emit(current_field)


func get_current_field() -> GravField:
	return current_field
