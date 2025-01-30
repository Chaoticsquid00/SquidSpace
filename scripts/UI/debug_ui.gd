extends VBoxContainer

@export var grav_field_label : RichTextLabel
@export var velocity_label : RichTextLabel

func _ready():
	grav_field_label.text = "Gravity Enabled: false"
	velocity_label.text = "Velocity: false"
	
	UISignalBus.grav_field_changed.connect(update_grav_field_label)
	UISignalBus.player_velocity_changed.connect(update_velocity_label)

func update_grav_field_label(grav_field : GravField):
	grav_field_label.text = "Gravity Enabled: " + str(grav_field != null)

func update_velocity_label(velocity : Vector3):
	velocity_label.text = "Velocity: " + str(velocity)
