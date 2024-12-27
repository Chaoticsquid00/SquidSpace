extends CanvasLayer

@onready var grav_label = $VBoxContainer/GravLabel
const GRAV_LABEL_STRING := "Gravity Enabled: "

@onready var player = $"../World/Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	grav_label.text = GRAV_LABEL_STRING + str(player.grav_field != null)
