extends CanvasGroup

@onready var game = $"../../"

func _process(delta):
	var scroll_speed:float = game.scroll_speed / Conductor.rate
	
	for i in get_child_count():
		var note:Note = get_child(i)
		var strum_pos:Vector2 = note.strumline.get_child(note.direction).global_position
		note.position.x = strum_pos.x
		note.position.y = strum_pos.y - (0.45 * (Conductor.position - note.time) * scroll_speed)

		if note.must_press:
			if note.time <= Conductor.position - (500 / scroll_speed):
				game.fake_miss(note.direction)
				note.queue_free()
		else:
			if note.time <= Conductor.position:
				var sing_anim:String = "sing"+game.cpu_strums.get_child(note.direction).direction.to_upper()
				game.opponent.play_anim(sing_anim, true)
				game.opponent.hold_timer = 0.0
				note.queue_free()
