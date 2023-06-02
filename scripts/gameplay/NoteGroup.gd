class_name NoteGroup extends CanvasGroup

@onready var game:Gameplay = $"../../../"

func _process(delta):
	for note in get_children():
		note = note as Note
		
		var downscroll_mult:int = -1
		
		var strumline:StrumLine = note.strumline
		var receptor:Receptor = note.strumline.get_child(note.direction)
		note.position.x = receptor.global_position.x
		note.position.y = receptor.global_position.y - ((0.45 * downscroll_mult) * (Conductor.position - note.time) * game.scroll_speed)
		
		if note.strumline.type != Tools.StrumLineType.PLAYER and note.time <= Conductor.position:
			strumline.play_anim(note.direction, Tools.ReceptorAnim.CONFIRM)
			note.queue_free()
		
		if note.time <= Conductor.position - (500 / game.scroll_speed):
			note.queue_free()
