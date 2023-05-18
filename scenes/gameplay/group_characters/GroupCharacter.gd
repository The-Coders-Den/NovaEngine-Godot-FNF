extends Node2D
class_name GroupCharacter

@export var current_focused_char:int = 0

func play_anim(anim:String, force:bool = false):
	for i in get_child_count():
		var character:Character = get_child(i)
		character.play_anim(anim, force)
		
func dance():
	for i in get_child_count():
		var character:Character = get_child(i)
		character.dance()
