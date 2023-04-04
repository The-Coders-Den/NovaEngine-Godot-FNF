@tool
extends AnimatedSprite2D
class_name AnimatedSprite

@export var playing:bool = false:
	set(value):
		if value:
			play(animation)
		else:
			pause()
	get:
		return playing
