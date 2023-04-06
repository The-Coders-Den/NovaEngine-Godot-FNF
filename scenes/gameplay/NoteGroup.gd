extends CanvasGroup

@onready var game:Gameplay = $"../../"

var note_anim_time:float = 0.0
var note_anim_time_player:float = 0.0

func _process(delta):
	note_anim_time += (delta * 1000.0) * Conductor.rate
	note_anim_time_player += (delta * 1000.0) * Conductor.rate
	
	var scroll_speed:float = game.scroll_speed / Conductor.rate
	
	for i in get_child_count():
		var downscroll_mult:int = -1 if SettingsAPI.get_setting("downscroll") else 1
		var note:Note = get_child(i)
		var strum_pos:Vector2 = note.strumline.get_child(note.direction).global_position
		note.position.x = strum_pos.x
		note.position.y = strum_pos.y - ((0.45 * downscroll_mult) * (Conductor.position - note.time) * scroll_speed)
		
		if note.was_good_hit:
			note.position.y = strum_pos.y
			
			if note.must_press and note_anim_time_player >= Conductor.step_crochet and Input.is_action_pressed(note.strumline.controls[note.direction]):
				var receptor:Receptor = note.strumline.get_child(note.direction)
				receptor.play_anim("confirm")
				
				var sing_anim:String = "sing"+note.strumline.get_child(note.direction).direction.to_upper()
				game.player.play_anim(sing_anim, true)
				game.player.hold_timer = 0.0
				game.voices.volume_db = 0
				
				note_anim_time_player = 0.0
			elif not note.must_press and note_anim_time >= Conductor.step_crochet:
				var sing_anim:String = "sing"+note.strumline.get_child(note.direction).direction.to_upper()
				game.opponent.play_anim(sing_anim, true)
				game.opponent.hold_timer = 0.0
				game.voices.volume_db = 0
				
				note_anim_time = 0.0

		var note_kill_range:float = (500 / scroll_speed)
		if note.must_press:
			if note.time <= Conductor.position - note_kill_range and not note.was_good_hit:
				note._player_miss()
				game.fake_miss(note.direction)
				note.queue_free()
		else:
			if note.time <= Conductor.position and note.should_hit and not note.was_good_hit:
				game.voices.volume_db = 0
				
				note.was_good_hit = true
				note.anim_sprite.visible = false
				note._cpu_hit()
				note._note_hit(false)
				
				var sing_anim:String = "sing"+game.cpu_strums.get_child(note.direction).direction.to_upper()
				game.opponent.play_anim(sing_anim, true)
				game.opponent.hold_timer = 0.0
				
				if note.length <= 0:
					note.queue_free()
					
			if note.time <= Conductor.position - note_kill_range and not note.should_hit and not note.was_good_hit:
				note._cpu_miss()
				note.queue_free()
