extends Node2D
class_name NoteGroup

@onready var game:Gameplay = $"../../"

var note_anim_time:float = 0.0
var note_anim_time_player:float = 0.0

func _process(delta:float) -> void:
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
				if not game.player.special_anim:
					var sing_anim:String = "sing%s" % note.strumline.get_child(note.direction).direction.to_upper()
					if note.alt_anim:
						sing_anim += "-alt"
					game.player.play_anim(sing_anim, true)
					game.player.hold_timer = 0.0
					
				note.is_sustain_note = true
				note._player_hit()
				note._note_hit(true)
				game.script_group.call_func("on_note_hit", [note])
				game.script_group.call_func("on_player_hit", [note])
			elif not note.must_press and note_anim_time >= Conductor.step_crochet:
				if not game.opponent.special_anim:
					var sing_anim:String = "sing%s" % note.strumline.get_child(note.direction).direction.to_upper()
					if note.alt_anim:
						sing_anim += "-alt"
						
					game.opponent.play_anim(sing_anim, true)
					game.opponent.hold_timer = 0.0
					
				note.is_sustain_note = true
				note._cpu_hit()
				note._note_hit(false)
				game.script_group.call_func("on_note_hit", [note])
				game.script_group.call_func("on_cpu_hit", [note])
				
		# don't ask >:(
		if note.must_press and note.was_good_hit and note_anim_time_player >= Conductor.step_crochet and Input.is_action_pressed(note.strumline.controls[note.direction]):
			var receptor:Receptor = note.strumline.get_child(note.direction)
			receptor.play_anim("confirm")

		var note_kill_range:float = (500 / scroll_speed)
		if note.must_press:
			if note.time <= Conductor.position - note_kill_range and not note.was_good_hit:
				if SettingsAPI.get_setting("miss sounds"):
					Audio.play_sound("missnote"+str(randi_range(1, 3)), randf_range(0.1, 0.3))
				
				note.is_sustain_note = false
				note._player_miss()
				game.fake_miss(note.direction)
				game.script_group.call_func("on_note_miss", [note])
				game.script_group.call_func("on_player_miss", [note])
				note.queue_free()
		else:
			if note.time <= Conductor.position and note.should_hit and not note.was_good_hit:
				note.was_good_hit = true
				note.anim_sprite.visible = false
				note._cpu_hit()
				note._note_hit(false)
				game.script_group.call_func("on_note_hit", [note])
				game.script_group.call_func("on_cpu_hit", [note])
				
				var sing_anim:String = "sing%s" % game.cpu_strums.get_child(note.direction).direction.to_upper()
				if note.alt_anim:
					sing_anim += "-alt"
					
				game.opponent.play_anim(sing_anim, true)
				game.opponent.hold_timer = 0.0
				
				if note.length <= 0:
					note.queue_free()
					
				game.skipped_intro = true # Can't skip something you already waited for!
				
			if note.time <= Conductor.position - note_kill_range and not note.should_hit and not note.was_good_hit:
				note.is_sustain_note = false
				note._cpu_miss()
				game.script_group.call_func("on_note_miss", [note])
				game.script_group.call_func("on_cpu_miss", [note])
				note.queue_free()
				
	# don't ask #2 >:(
	if note_anim_time >= Conductor.step_crochet:
		note_anim_time = 0.0
			
	if note_anim_time_player >= Conductor.step_crochet:
		note_anim_time_player = 0.0
