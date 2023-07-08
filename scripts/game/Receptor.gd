class_name Receptor extends Node2D

@onready var strum_line:StrumLine = $"../../"

@onready var sprite = $Sprite
@onready var splash:AnimatedSprite2D

var direction:int = -1
var pressed:bool = false

func unfuck():
	if has_node("Splash"):
		splash = get_node("Splash")
	else:
		splash = strum_line.get_node("splash_%s" % str(direction))
	
	splash.animation_finished.connect(func():
		splash.visible = false
		splash.process_mode = Node.PROCESS_MODE_DISABLED
	)
	
	if not sprite is AnimatedSprite2D or not strum_line.autoplay:
		return
		
	sprite = sprite as AnimatedSprite2D
	sprite.animation_finished.connect(func():
		if sprite.animation.ends_with("confirm"):
			sprite.frame = 0
			sprite.play(sprite.animation.replace("confirm", "static"))
	)

func _ready():
	unfuck()
	script_changed.connect(unfuck)
