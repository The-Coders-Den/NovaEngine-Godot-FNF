extends Node2D

@onready var strum_line:StrumLine = $"../"
@onready var receptors:Node2D = $"../Receptors"
@onready var game:Gameplay = $"../../../../../"

var anim_timer:float = 0.0

func _process(delta:float):
	anim_timer += delta * 1000.0
	
	for note in get_children():
		note = note as Note
		
		var downscroll_mult:int = -1 if strum_line.downscroll else 1
		var receptor:Receptor = receptors.get_child(note.direction)
		var note_speed:float = _get_note_speed(note)
		
		note.position.x = receptor.position.x
		
		if note.was_already_hit:
			note.position.y = receptor.position.y
			
			note.length -= delta * 1000.0
			if note.length <= -Conductor.step_crochet:
				note.queue_free()
				
			if not strum_line.autoplay and note.length >= 80.0 and not Input.is_action_pressed("note_%s" % StrumLine.NoteDirection.keys()[note.direction].to_lower()) and not note.missed:
				note.was_already_hit = false
				note.missed = true
				game.note_miss(note.direction)
		else:
			note.position.y = receptor.position.y - ((0.45 * downscroll_mult) * (Conductor.position - note.hit_time) * note_speed)
		
		if note.sustain.visible:
			note.sustain.position.x = (note.sustain.size.x * absf(note.sustain.scale.x))
			
			var calculated_height:float = ((note.length * 0.5) * note_speed) / absf(note.sustain.scale.y)
			if calculated_height < 15:
				note.sustain.self_modulate.a = 0.0
			
			note.sustain.size.y = calculated_height
			note.sustain_end.position.y = calculated_height
			
			if note.sustain_end is AnimatedSprite2D:
				var end := note.sustain_end as AnimatedSprite2D
				end.position.x = (end.sprite_frames.get_frame_texture(end.animation, 0).get_width() * end.scale.x) * 0.5
				end.position.y += (end.sprite_frames.get_frame_texture(end.animation, end.frame).get_height() * end.scale.y) * 0.5
			else:
				var end := note.sustain_end as Sprite2D
				end.position.x = (end.texture.get_width() * end.scale.x) * 0.5
				end.position.y += (end.texture.get_height() * end.scale.y) * 0.5
		
		if (strum_line.autoplay or receptor.pressed) and note.was_already_hit and anim_timer >= Conductor.step_crochet:
			if not strum_line.autoplay:
				game.health += 0.0115
				
			strum_line.play_anim(note.direction, "confirm")
			
		if note.missed:
			note.length = note.og_length
			note.sustain_clip_rect.clip_contents = false
			note.modulate.a = 0.3
		
		if strum_line.autoplay and note.hit_time < Conductor.position and note.should_hit and note.hit_allowed and not note.was_already_hit:
			note.hit_allowed = false
			
			var event := NoteHitEvent.new(note, note.direction, 0.023)
			game.call_on_modcharts("on_note_hit", [event])
			
			if not event.cancelled:
				strum_line.play_anim(note.direction, "confirm")
				note.was_already_hit = true
				note.sprite.visible = false
				if note.length <= 0:
					note.queue_free()
				
			event.unreference()
		
		if note.hit_time < Conductor.position - (500 / note_speed) and not note.was_already_hit and not note.missed:
			var event := NoteMissEvent.new(note, note.direction, 0.0475)
			game.call_on_modcharts("on_note_miss", [event])
			
			# Cancelling the event won't matter here
			note.missed = true
			if not strum_line.autoplay:
				game.note_miss(note.direction, null, event)
			
			event.unreference()
			
		if note.hit_time < Conductor.position - ((500 + (note.length * 4.3)) / note_speed) and not note.was_already_hit and note.missed:
			note.queue_free()
			
	if anim_timer >= Conductor.step_crochet:
		anim_timer = 0.0
		
func _get_note_speed(note:Note):
	if strum_line.scroll_speed != -INF:
		return strum_line.scroll_speed / Conductor.rate
	
	if note.scroll_speed != -INF:
		return note.scroll_speed / Conductor.rate
		
	if game.scroll_speed != -INF:
		return game.scroll_speed / Conductor.rate
			
	return Gameplay.CHART.scroll_speed / Conductor.rate
