extends Label
var time:float = 0.0
@export var text_rate:float = 0.05
@onready var type_sound = $"../../type_sound"


func _ready():
	visible_characters = 0
func _process(delta):
	time += delta
	if time >= text_rate and visible_characters <= text.length():
		time = 0.0
		visible_characters += 1
		type_sound.play()
