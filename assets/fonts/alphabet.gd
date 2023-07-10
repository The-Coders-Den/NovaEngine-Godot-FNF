@tool
@icon("res://assets/godot Editer/icons/alphabet.png")
class_name Alphabet extends Control
var frames:SpriteFrames = preload("res://assets/fonts/alphabet/bold.res")
var letters:Array[AnimatedSprite2D] = []
@export var text:String = "":
	set(v):
		text = v
		for i in letters:
			i.queue_free()
		letters = []
		var index:float = 0
		for letter in text:
			if letter == " ":
				index += 0.5
				continue
			index += 1
			var new_sprite:AnimatedSprite2D = AnimatedSprite2D.new()
			new_sprite.centered = false
			new_sprite.sprite_frames = frames
			new_sprite.play(letter.to_upper())
			letters.append(new_sprite)
			add_child(new_sprite)
			new_sprite.position.x = ((index-1) * 55.0)
			size.y = new_sprite.sprite_frames.get_frame_texture(new_sprite.animation,new_sprite.frame).get_size().y + 5.0
		size.x = (index*55.0) - 10.0
