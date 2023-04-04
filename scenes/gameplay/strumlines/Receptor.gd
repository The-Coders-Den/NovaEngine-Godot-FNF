extends AnimatedSprite
class_name Receptor

@export_enum("left", "down", "up", "right")
var direction:String = "left"

func _ready():
	play_anim("static")

func play_anim(name:String):
	frame = 0
	match name.to_lower():
		"hit", "confirm", "glow":
			play(direction+" confirm")
		"press", "pressed":
			play(direction+" pressed")
		_:
			play(direction+" static")
