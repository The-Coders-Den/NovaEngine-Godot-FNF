class_name NoteGroup extends CanvasGroup

@onready var game:Gameplay = $"../../../../"

func _process(delta:float):
	for note in get_children():
		note = note as Note
		
		var downscroll_mult:int = -1 if note.strumline.downscroll else 1
		var receptor:Receptor = note.strumline.receptors.get_child(note.direction)
		
		if note.strumline.type != StrumLine.StrumLineType.PLAYER and note.time <= Conductor.position:
			other_note_hit(note, note.strumline.type)
			continue
		
		if note.time <= Conductor.position - (500 / _get_note_speed(note)):
			note.queue_free()
			continue
		
		note.position.x = receptor.position.x
		note.position.y = receptor.position.y - ((0.45 * downscroll_mult) * (Conductor.position - note.time) * _get_note_speed(note))
		if note.material is ShaderMaterial:
			note.material.set_shader_parameter("enabled",note.dynamic_note_colors)
			note.material.set_shader_parameter("color",note.colors[note.direction])

func other_note_hit(note:Note, type:StrumLine.StrumLineType):
	note.was_already_hit = true
	note.queue_free()

func _get_note_speed(note:Note):
	if note.strumline.scroll_speed != -INF:
		return note.strumline.scroll_speed / Conductor.rate
		
	var receptor:Receptor = note.strumline.receptors.get_child(note.direction)
	if receptor.scroll_speed != -INF:
		return receptor.scroll_speed / Conductor.rate
		
	if note.scroll_speed != -INF:
		return note.scroll_speed / Conductor.rate
		
	if game.scroll_speed != -INF:
		return game.scroll_speed / Conductor.rate
			
	return Global.CHART.scroll_speed / Conductor.rate
