@tool
extends AnimatedSprite2D

@export var playing:bool = false:
	set(value):
		if value:
			play(animation)
		else:
			pause()
	get:
		return playing

 # This makes animation handling for things that aren't chars a bit better.
var anim_player:AnimationPlayer:
	get:
		return get_child(0)
