extends CanvasLayer

var options:PackedStringArray = [
	"Resume",
	"Restart Song",
	"Exit To Menu"
]

@onready var game:Gameplay = $"../"

func _ready():
	get_tree().paused = true

func _process(delta):
	if Input.is_action_just_pressed("ui_pause"):
		get_tree().paused = false
		queue_free()
