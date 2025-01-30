extends CanvasLayer

@export var grav_label : RichTextLabel
const GRAV_LABEL_STRING := "Gravity Enabled: "

@onready var player = $"../World/Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
