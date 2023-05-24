extends CanvasLayer

var options:PackedStringArray = [
	"Resume",
	"Restart Song",
	"Skip Time",
	"Skip Intro",
	"Change Options",
	"Exit To Menu"
]
var cur_selected:int = 0

var music_volume:float = 0.0
var final_volume:float = 0.5

var cur_time:float = Conductor.position
var hold_time:float = 0.0

@onready var game:Gameplay = $"../"
@onready var text_template:FreeplayAlphabet = $__TemplateItem__

@onready var bg:ColorRect = $BG
@onready var menu_items:Node2D = $MenuItems
@onready var music:AudioStreamPlayer = $Music

@onready var song_name:Label = $SongName
@onready var difficulty:Label = $Difficulty

@onready var skip_time_label:Label = $SkipTimeLabel

func _ready() -> void:
	get_tree().paused = true
	
	music.volume_db = -80
	music.play(randf_range(0.0, music.stream.get_length() * 0.5))
	music.stream.loop = true
	
	if game.skipped_intro:
		options.remove_at(options.find("Skip Intro"))
	
	for i in options.size():
		var option:String = options[i]
		
		var new_item:FreeplayAlphabet = text_template.duplicate()
		new_item.position = Vector2(0, (70 * i) + 30)
		new_item.text = option
		new_item.is_menu_item = true
		new_item.target_y = i
		new_item.visible = true
		new_item.is_template = false
		menu_items.add_child(new_item)
		
		if option == "Skip Time":
			remove_child(skip_time_label)
			new_item.add_child(skip_time_label)
			
			skip_time_label.position.x = new_item.size.x + 50
		
	change_selection()
		
	song_name.modulate.a = 0.0
	difficulty.modulate.a = 0.0
	
	song_name.text = Global.SONG.name
	difficulty.text = Global.current_difficulty.to_upper()
	
	await get_tree().create_timer(0.05).timeout
	
	song_name.position.x = Global.game_size.x - (song_name.size.x + 10)
	difficulty.position.x = Global.game_size.x - (difficulty.size.x + 10)

	var bg_tween:Tween = create_tween()
	bg_tween.tween_property(bg, "modulate:a", 0.6, 0.4)
	bg_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	
	var tween:Tween = create_tween().set_parallel()
	tween.tween_property(song_name, "modulate:a", 1, 0.4).set_delay(0.3)
	tween.tween_property(song_name, "position:y", song_name.position.y + 5, 0.4).set_delay(0.3)
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	
	var tween2:Tween = create_tween().set_parallel()
	tween2.tween_property(difficulty, "modulate:a", 1, 0.4).set_delay(0.5)
	tween2.tween_property(difficulty, "position:y", difficulty.position.y + 5, 0.4).set_delay(0.5)
	tween2.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	
func change_selection(change:int = 0):
	cur_selected = wrapi(cur_selected + change, 0, options.size())
	
	for i in menu_items.get_child_count():
		var item:FreeplayAlphabet = menu_items.get_child(i)
		item.target_y = i - cur_selected
		item.modulate.a = 1.0 if cur_selected == i else 0.6
		
	skip_time_label.visible = options[cur_selected] == "Skip Time"
	Audio.play_sound("scrollMenu")

func _process(delta):
	var length:float = game.note_data_array[game.note_data_array.size()-1].time + game.meta.end_offset if game.note_data_array.size() > 0 else game.tracks[0].stream.get_length() * 1000.0
	skip_time_label.text = "%s / %s" % [Global.format_time(cur_time / 1000.0), Global.format_time(length / 1000.0)]
	
	music_volume = clampf(music_volume + (0.01 * delta), 0.0, final_volume)
	music.volume_db = linear_to_db(music_volume)
	
	match options[cur_selected]:
		"Skip Time":
			if Input.is_action_just_pressed("ui_left"):
				cur_time = clampf(cur_time - 1000.0, 0.0, length)
				
			if Input.is_action_just_pressed("ui_right"):
				cur_time = clampf(cur_time + 1000.0, 0.0, length)
				
			if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
				hold_time += delta
				if hold_time > 0.5:
					hold_time = 0.435
					if Input.is_action_pressed("shift_key"):
						hold_time = 0.475
					cur_time = clampf(cur_time + (1000.0 * (-1.0 if Input.is_action_pressed("ui_left") else 1.0)), 0.0, length)
			else:
				hold_time = 0.0
				
	if Input.is_action_just_pressed("ui_accept"):
		match options[cur_selected]:
			"Resume":
				get_tree().paused = false
				game.resync_tracks()
				queue_free()
				
			"Restart Song":
				Global.reset_scene()
				queue_free()
				
			"Skip Time":
				# Remove bad notes
				var old_pos:float = Conductor.position
									
				if cur_time != Conductor.position:
					if game.countdown_timer != null:
						game.countdown_timer.unreference()
						game.countdown_timer = null
						
					if game.starting_song:
						game.start_song()
						
					game.score = 0 # fuck you i'm lazy
					Conductor.position = cur_time
					
					if cur_time > old_pos:
						while game.note_data_array.size() > 0:
							if game.note_data_array[0].time >= cur_time + 500: break
							game.note_data_array.pop_front()
							
						while game.note_group.get_child_count() > 0:
							var c = game.note_group.get_child(0)
							c.queue_free()
							game.note_group.remove_child(c)
					else:
						game.note_data_array = []
						game.gen_song(cur_time + 500)
						Conductor.change_bpm(Global.SONG.bpm)
						
				game.load_events()
				
				get_tree().paused = false
				game.resync_tracks()
				
				queue_free()
				
			"Skip Intro":
				game.skip_intro()
				get_tree().paused = false
				queue_free()
				
			"Change Options":
				Audio.play_music("freakyMenu")
				
				Global.scene_arguments["options_menu"].exit_scene_path = "res://scenes/gameplay/Gameplay.tscn"
				Global.switch_scene("res://scenes/OptionsMenu.tscn")
				queue_free()
				
			"Exit To Menu":
				Audio.play_music("freakyMenu")
				
				Global.queued_songs = []
				Global.switch_scene("res://scenes/FreeplayMenu.tscn" if !Global.is_story_mode else "res://scenes/StoryMenu.tscn")
				queue_free()
	
	if Input.is_action_just_pressed("ui_up"):
		change_selection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_selection(1)
