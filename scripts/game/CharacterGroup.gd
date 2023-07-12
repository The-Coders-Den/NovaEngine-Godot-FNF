extends Node2D
func sing(direction:int):
	for i in get_children():
		if not i is Character:
			continue
		i = i as Character
		i.play_anim("sing%s" % StrumLine.NoteDirection.keys()[direction])
func dance(force:bool = false):
	for i in get_children():
		if not i is Character:
			continue
		i = i as Character
		i.dance()
