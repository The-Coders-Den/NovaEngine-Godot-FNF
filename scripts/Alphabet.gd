@tool
@icon("res://assets/godot_editor/icons/alphabet.png")
class_name Alphabet extends Control

var frames:SpriteFrames = preload("res://assets/fonts/alphabet/bold.res")
var letters:Array[AnimatedSprite2D] = []

var fart_size:Vector2 = Vector2.ZERO

@export_multiline var text:String = "":
	set(v):
		text = v
		for i in letters:
			i.queue_free()
		letters = []
		var letter_pos:Vector2 = Vector2.ZERO
		
		fart_size = Vector2.ZERO
		var lines:PackedStringArray = text.split("\n")
		
		var i:int = 0
		for text in lines:
			letter_pos.x = 0.0
			
			for letter in text:
				if letter == " ":
					letter_pos.x += 30.0
					fart_size.x += 30.0
					continue
				
				var new_sprite:AnimatedSprite2D = AnimatedSprite2D.new()
				new_sprite.centered = false
				new_sprite.sprite_frames = frames
				new_sprite.play(letter.to_upper())
				letters.append(new_sprite)
				add_child(new_sprite)
				
				var sprite_size:Vector2 = new_sprite.sprite_frames.get_frame_texture(new_sprite.animation,new_sprite.frame).get_size()
				new_sprite.position = letter_pos
				fart_size.x += sprite_size.x
				letter_pos.x += sprite_size.x
				
			letter_pos.y += 60.0
			fart_size.y += 60.0
			i += 1
		
		fart_size.y += 5.0
		size = fart_size
		
func _process(delta):
	size = fart_size
