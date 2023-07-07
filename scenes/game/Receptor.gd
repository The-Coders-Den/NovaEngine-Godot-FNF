class_name Receptor extends Node2D

@onready var strum_line:StrumLine = $"../../"

@onready var sprite = $Sprite
@onready var splash:AnimatedSprite2D = $Splash

var pressed:bool = false

func _ready():
	if not sprite is AnimatedSprite2D or not strum_line.autoplay:
		return
		
	sprite = sprite as AnimatedSprite2D
	sprite.animation_finished.connect(func():
		if sprite.animation.ends_with("confirm"):
			sprite.frame = 0
			sprite.play(sprite.animation.replace("confirm", "static"))
	)
