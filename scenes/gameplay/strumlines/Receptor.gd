extends AnimatedSprite
class_name Receptor
@export_enum("left", "down", "up", "right")
var direction:String = "left"

@onready var splash:AnimatedSprite2D = $Splash

func _ready() -> void:
	play_anim("static")
	splash.animation_finished.connect(func(): splash.visible = false)
	speed_scale = Conductor.rate

func play_anim(name:String) -> void:
	frame = 0
	match name.to_lower():
		"hit", "confirm", "glow":
			play(direction+" confirm")
		"press", "pressed":
			play(direction+" pressed")
		_:
			play(direction+" static")
