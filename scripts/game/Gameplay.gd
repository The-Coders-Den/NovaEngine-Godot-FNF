class_name Gameplay extends Node2D

enum GameMode {
	STORY,
	FREEPLAY
}

#-- statics --#
static var CHART:Chart
static var GAME_MODE:GameMode = GameMode.FREEPLAY

#-- normals --#
@onready var camera:Camera2D = $Camera2D
@onready var hud:Node2D = $HUDContainer/HUD

@onready var strum_lines:Node2D = $HUDContainer/HUD/StrumLines
@onready var opponent_strums:StrumLine = $HUDContainer/HUD/StrumLines/OpponentStrums
@onready var player_strums:StrumLine = $HUDContainer/HUD/StrumLines/PlayerStrums

@onready var opponent_list:Array[Character] = []
@onready var spectator_list:Array[Character] = []
@onready var player_list:Array[Character] = []

@onready var opponent:Character:
	get:
		return opponent_list[0]
		
@onready var spectator:Character:
	get:
		return spectator_list[0]
		
@onready var player:Character:
	get:
		return player_list[0]

@onready var health_bar:ProgressBar = $HUDContainer/HUD/HealthBar
@onready var character_icons:Node2D = $HUDContainer/HUD/HealthBar/Icons
@onready var score_text:Label = $HUDContainer/HUD/HealthBar/ScoreText

@onready var ratings:Node2D = $Ratings
@onready var judgement_template:Sprite2D = $Ratings/JudgementTemplate
@onready var combo_template:Sprite2D = $Ratings/ComboTemplate

@onready var countdown_sprite:Sprite2D = $ParallaxNode/CountdownSprite

## A list of every note type able to spawn.
var template_notes:Dictionary = {
	"default": preload("res://scenes/game/notes/Default.tscn").instantiate()
}

## The audio files for this song.
var tracks:Array[AudioStreamPlayer] = []

## Keeps track of what tracks are finished.
var finished_tracks:Array[bool] = []

## The list of notes that haven't been spawned yet.
var notes_to_spawn:Array[Chart.ChartNote] = []

## The scroll speed of the notes.
## Can also be modified per strumline.
var scroll_speed:float = -INF

## Whether or not the song is starting.
var starting_song:bool = true

## Whether or not the song is ending.
var ending_song:bool = false

## The currently loaded stage.
var stage:Stage

## The list of every modchart loaded.
## Includes song specific & global modcharts.
var modcharts:Array[Modchart] = []

var score:int = 0
var misses:int = 0
var combo:int = 0

var accuracy:float:
	get:
		if accuracy_total_hit != 0.0 and accuracy_hit_notes != 0:
			return accuracy_total_hit / (accuracy_hit_notes + misses)
			
		return 0.0
		
var health:float:
	get:
		return health_bar.value
		
	set(v):
		health_bar.value = v
		
## Whether or not the camera can zoom out
## after bumping.
var cam_zooming:bool = true

## How often the camera bumps.
## Default is the song's beats per measure (usually 4).
var cam_zooming_interval:int = 4

## Controls how much the camera zooms out
## to after bumping.
var default_cam_zoom:float = 1.05

## The characters of a specified strumline
## to focus on.
var cur_camera_target:int = 0

var accuracy_total_hit:float = 0.0
var accuracy_hit_notes:int = 0

var consecutive_misses:float = 0.0

var note_style:NoteStyle
var ui_style:UIStyle

func load_notes(delete_before_time:float = -INF):
	notes_to_spawn = []
	
	for note in CHART.notes:
		if note.hit_time <= delete_before_time:
			continue
				
		var new_note:Chart.ChartNote = note.duplicate(true)
		new_note.hit_time += Options.note_offset
		notes_to_spawn.append(new_note)
		
		if not note.type in template_notes:
			var path:String = "res://scenes/game/notes/%s.tscn" % note.type
			if not ResourceLoader.exists(path):
				printerr("Note type of \"%s\" doesn't exist! Loading default instead." % note.type)
				path = "res://scenes/game/notes/Default.tscn"
			
			template_notes[note.type] = load(path).instantiate()
		
	notes_to_spawn.sort_custom(func(a:Chart.ChartNote, b:Chart.ChartNote): return a.hit_time < b.hit_time)

func load_tracks():
	var base_path:String = "res://assets/songs/%s/music" % CHART.song_name
	var i:int = 0
	for shit in DirAccess.open(base_path).get_files():
		if not shit.ends_with(".import"):
			continue
			
		var track := AudioStreamPlayer.new()
		track.stream = load("%s/%s" % [base_path, shit.replace(".import", "")])
		track.pitch_scale = Conductor.rate
		tracks.append(track)
		finished_tracks.append(false)
		track.finished.connect(func(): finished_tracks[i] = true)
		add_child(track)
		
		i += 1
		
func call_on_modcharts(method:String, args:Array[Variant]):
	for modchart in modcharts:
		if not is_instance_valid(modchart) or modchart.is_event:
			continue
			
		modchart.call_method(method, args)
		
var _loaded_events:Dictionary = {}
		
func load_events():
	for group in CHART.events:
		for event in group.events:
			if event.name in _loaded_events:
				continue
				
			var modchart:Modchart = null
			var event_path:String = "res://assets/data/events/%s.tscn" % event.name
			var event_gdpath:String = "res://assets/data/events/%s.gd" % event.name
			
			if ResourceLoader.exists(event_path):
				modchart = load(event_path).instantiate()
			elif FileAccess.file_exists(event_gdpath) or FileAccess.file_exists(event_gdpath+"c"):
				modchart = Modchart.new()
				modchart.set_script(load(event_gdpath))
			else:
				printerr("Event doesn't exist (or is hardcoded): %s" % event.name)
				
			if is_instance_valid(modchart):
				print("Loaded event: %s" % event.name)
				modchart.game = self
				modchart.is_event = true
				modcharts.append(modchart)
				add_child(modchart)
			
			_loaded_events[event.name] = modchart
	
func load_modchart_from_path(path:String):
	var modchart:Modchart = load(path).instantiate()
	modchart.game = self
	return modchart
	
func load_modchart_from_gdpath(path:String):
	var modchart:Modchart = Modchart.new()
	modchart.set_script(load(path))
	modchart.game = self
	return modchart
		
func load_modcharts():
	# Song specific and global
	for script_path in [
		"res://assets/songs/%s/modcharts/" % CHART.song_name,
		"res://assets/modcharts/"
	]:
		if not DirAccess.dir_exists_absolute(script_path):
			continue
		
		for item in DirAccess.open(script_path).get_files():
			if item.ends_with(".tscn") or item.ends_with(".tscn.remap"):
				var modchart:Modchart = load_modchart_from_path(script_path+item.replace(".remap", ""))
				modcharts.append(modchart)
				add_child(modchart)
				continue
				
			if (item.ends_with(".gd") or item.ends_with(".gdc")) and not ResourceLoader.exists(script_path+item.replace(".gdc", "").replace(".gd", "")+".tscn"):
				var modchart:Modchart = load_modchart_from_gdpath(script_path+item.replace(".gdc", ".gd"))
				modcharts.append(modchart)
				add_child(modchart)
				continue
		
func is_track_synced(track:AudioStreamPlayer):
	# i love windows
	var ms_allowed:float = (25 if OS.get_name() == "Windows" else 15) * track.pitch_scale
	var track_time:float = track.get_playback_position() * 1000.0
	return !(absf(track_time - Conductor.position) > ms_allowed)

func update_score_text():
	var event := CancellableEvent.new()
	call_on_modcharts("on_update_score_text", [event])
	
	if not event.cancelled:
		var sep:String = " • "
		score_text.text = "< "
		score_text.text += "Score: %s" % str(score)
		score_text.text += "%sAccuracy: %.2f%s" % [sep, accuracy * 100.0, "%"]
		score_text.text += "%sCombo Breaks: %s" % [sep, str(misses)]
		score_text.text += "%sRank: %s" % [sep, Timings.get_rank(accuracy * 100.0).name]
		score_text.text += " >"
	
	event.unreference()
	
func load_character(data:Chart.ChartCharacter):
	if data.strum_index >= strum_lines.get_child_count():
		return
		
	var character:Character = null
	
	var char_path:String = "res://scenes/game/characters/%s.tscn" % data.name
	if ResourceLoader.exists(char_path):
		character = load(char_path).instantiate()
	else:
		character = load("res://scenes/game/characters/bf.tscn").instantiate()
		
	var positions:Array[Node2D] = [
		stage.character_positions.get_node("Opponent"),
		stage.character_positions.get_node("Player"),
		stage.character_positions.get_node("Spectator"),
	]
	
	var strum_line:StrumLine = strum_lines.get_child(data.strum_index) as StrumLine
	
	character.position = positions[data.position].position
		
	match data.position:
		Chart.CharacterPosition.SPECTATOR:
			spectator_list.append(character)
			
		Chart.CharacterPosition.OPPONENT:
			opponent_list.append(character)
			
		Chart.CharacterPosition.PLAYER:
			character._is_true_player = true
			player_list.append(character)
	
	var size:int = strum_line.characters.size()
	character.position += Vector2(size * 40, size * -10)
	
	strum_line.characters.append(character)
	add_child(character)

func _ready():
	var old:float = Time.get_ticks_msec()
	if CHART == null:
		CHART = Chart.load_chart("fill up", "hard")
		printerr("Chart unable to be found! Loading fallback...")
	
	# load note & ui styles
	for shit in [".res", ".tres"]:
		var np:String = "res://assets/data/notestyles/%s%s" % [CHART.note_style, shit]
		if ResourceLoader.exists(np):
			note_style = load(np)
			
		var up:String = "res://assets/data/uistyles/%s%s" % [CHART.ui_style, shit]
		if ResourceLoader.exists(up):
			ui_style = load(up)
	
	# prepare song
	Conductor.setup_song(CHART)
	Conductor.position = Conductor.crochet * -4
	cam_zooming_interval = Conductor.beats_per_measure
	
	# load stage and characters
	var stage_path:String = "res://scenes/game/stages/%s.tscn" % CHART.stage
	var default_stage:String = "res://scenes/game/stages/stage.tscn"
	
	# error handling!!! now where's that codename
	if ResourceLoader.exists(stage_path):
		stage = load(stage_path).instantiate()
	elif ResourceLoader.exists(default_stage):
		printerr("Stage called \"%s\" doesn't exist! Loading default." % CHART.stage)
		stage = load(default_stage).instantiate()
	else:
		printerr("Failed to load default stage!")
		stage = Stage.new()
		
	add_child(stage)
	
	for char in CHART.characters:
		load_character(char)
		
	update_health_bar()
	
	default_cam_zoom = stage.default_cam_zoom
	camera.zoom = Vector2(default_cam_zoom, default_cam_zoom)
	
	# chcartcesrs
	# TODO: make these work
	
	ratings.move_to_front()
	
	# load chart notes, events & music
	load_notes()
	load_events()
	load_tracks()
	
	# position strums
	if Options.downscroll:
		opponent_strums.downscroll = true
		player_strums.downscroll = true
		
		opponent_strums.position.y *= -1
		player_strums.position.y *= -1
		
		health_bar.position.y *= -1
		health_bar.position.y -= 20
		
	# do steppering
	Conductor.beat_hit.connect(_beat_hit)
	Conductor.step_hit.connect(_step_hit)
	Conductor.measure_hit.connect(_measure_hit)
	
	# misc
	update_score_text()
	load_modcharts()
	
	opponent_strums.prepare_anims()
	player_strums.prepare_anims()
	
	call_on_modcharts("_ready_post", [])
	
func do_note_spawning():
	for note in notes_to_spawn:
		if note.hit_time > Conductor.position + (1500 / _get_note_speed(note)):
			break
			
		var new_note:Note = template_notes[note.type].duplicate()
		new_note.hit_time = note.hit_time
		new_note.direction = note.direction
		new_note.og_length = note.length * 0.7
		new_note.length = new_note.og_length
		new_note.type = note.type
		new_note.strum_line = strum_lines.get_child(note.strum_index)
		new_note.position = Vector2(-9999, -9999)
		new_note.strum_line.notes.add_child(new_note)
		
		new_note.has_splash = new_note.has_node("Splash")
		if new_note.has_splash:
			new_note.splash = new_note.get_node("Splash")
		
		if new_note.sprite is AnimatedSprite2D:
			var spr := new_note.sprite as AnimatedSprite2D
			var dir_str:String = StrumLine.NoteDirection.keys()[note.direction].to_lower()
			
			if note.length > 0.0:
				spr.play("%s hold piece" % dir_str)
				new_note.sustain.texture = spr.sprite_frames.get_frame_texture(spr.animation, 0)
				new_note.sustain_clip_rect.visible = true
				new_note.sustain.size.x = 0
				new_note.sustain_end.play("%s hold end" % dir_str)
				
				if Options.downscroll:
					new_note.sustain_clip_rect.scale.y *= -1.0
			
			spr.play(dir_str)
			
		# thank you godot for making this the simplest shit ever
		if Options.sustain_layer == Options.SustainLayer.BEHIND:
			new_note.sustain.z_index = -1
			
		var last_note:Note = null
		for fart_note in new_note.strum_line.notes.get_children():
			fart_note = fart_note as Note
			
			if last_note != null and absf(fart_note.hit_time - last_note.hit_time) <= 5 and last_note.direction == fart_note.direction:
				print("you have been BANNED from the mickey clubhouse for inappropate behavor")
				fart_note.queue_free()
			
			last_note = fart_note
			
		notes_to_spawn.erase(note)
		
func do_splash(receptor:Receptor, note:Note):
	var anim:String = "%s%s" % [StrumLine.NoteDirection.keys()[note.direction].to_lower(), str(randi_range(1,2))]
	
	if note.has_splash:
		var splash:AnimatedSprite2D = note.splash
		
		note.remove_child(splash)
		note.strum_line.add_child(splash)
		
		splash.visible = true
		splash.process_mode = Node.PROCESS_MODE_INHERIT
		
		splash.position = receptor.position
		splash.play(anim)
		
		splash.animation_finished.connect(splash.queue_free)
	else:
		var splash:AnimatedSprite2D = receptor.splash
		splash.visible = true
		splash.process_mode = Node.PROCESS_MODE_INHERIT
		
		splash.position = receptor.position
		splash.frame = 0
		splash.play(anim)
		
func note_miss(direction:int, note:Note = null, event:NoteMissEvent = null):
	combo = 0
	misses += 1
	
	if consecutive_misses == 0:
		consecutive_misses = 1
		
	health -= (event.health_loss if event != null else 0.0475) * consecutive_misses
	consecutive_misses += 0.175
	
	var strum_line:StrumLine = (note.strum_line if note != null else player_strums) as StrumLine
	for character in strum_line.characters:
		character = character as Character
		if not character.is_animated:
			continue
		
		character.hold_timer = 0.0
		character.play_anim("sing%smiss" % StrumLine.NoteDirection.keys()[direction], true)
	
	if note != null:
		note.queue_free()
		
	update_score_text()
	
func display_judgement(judgement:Timings.Judgement, event:JudgementEvent) -> VelocitySprite:
	call_on_modcharts("on_display_judgement", [event])
	
	var sprite:VelocitySprite = null
	if not event.cancelled:
		sprite = judgement_template.duplicate() as VelocitySprite
			
		sprite.texture = ui_style.rating_texture
		sprite.scale = Vector2(ui_style.rating_scale, ui_style.rating_scale)
		sprite.hframes = 2
		sprite.vframes = 6
		
		if accuracy == 1:
			sprite.frame = 0
		else:
			sprite.frame = (Timings.judgements.find(judgement) * 2) + (1 if event.late else 0) + 2
		
		sprite.position = judgement_template.position
		sprite.acceleration.y = 550
		sprite.velocity.y = -randi_range(140, 175)
		sprite.velocity.x = -randi_range(0, 10)
		sprite.visible = true
		sprite.moving = true
		sprite.modulate.a = 1.0
		
		var tween := create_tween()
		var penis := tween.tween_property(sprite, "modulate:a", 0.0, 0.2).set_delay(Conductor.crochet * 0.001)
		penis.finished.connect(sprite.queue_free)
		event.judgement_tween = tween
	
	event.judgement_sprite = sprite
	call_on_modcharts("on_display_judgement_post", [event])
	return event.judgement_sprite
	
func display_combo(combo:int, event:JudgementEvent) -> Array[VelocitySprite]:
	call_on_modcharts("on_display_combo", [event])
	
	var numbers:PackedStringArray = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
	var sprites:Array[VelocitySprite] = []
	
	if not event.cancelled:
		var i:int = 0
		var split_combo:PackedStringArray = str(combo).split()
		
		for num in split_combo:
			var sprite:VelocitySprite = combo_template.duplicate() as VelocitySprite
				
			sprite.texture = ui_style.combo_texture
			sprite.scale = Vector2(ui_style.combo_scale, ui_style.combo_scale)
			sprite.hframes = 11
			sprite.vframes = 2
				
			sprite.frame = int(num) + 1
			if accuracy == 1: sprite.frame += 11
			
			sprite.acceleration.y = randi_range(200, 300)
			sprite.velocity.y = -randi_range(140, 160)
			sprite.velocity.x = -randf_range(-5.0, 5.0)
			sprite.position = combo_template.position
			sprite.position.x += i * 43
			sprite.visible = true
			sprite.moving = true
			sprite.modulate.a = 1.0
			sprites.append(sprite)
			
			var tween := create_tween()
			var penis := tween.tween_property(sprite, "modulate:a", 0.0, 0.2).set_delay(Conductor.crochet * 0.002)
			penis.finished.connect(sprite.queue_free)
			
			i += 1
	
	event.combo_sprites = sprites
	call_on_modcharts("on_display_combo_post", [event])
	return event.combo_sprites
	
func pop_up_score(judgement:Timings.Judgement, combo:int, late:bool) -> JudgementEvent:
	var event := JudgementEvent.new(judgement, combo, late, null, [], [], [])
	call_on_modcharts("on_pop_up_score", [event])
	
	if not event.cancelled:
		var rating_spr := display_judgement(judgement, event)
		if rating_spr != null:
			ratings.add_child(rating_spr)
		
		var combo_sprs := display_combo(combo, event)
		for spr in combo_sprs:
			ratings.add_child(spr)
	
	call_on_modcharts("on_pop_up_score_post", [event])
	return event
		
func good_note_hit(note:Note, event:NoteHitEvent = null):
	if note.reset_combo_on_hit:
		combo = 0
	else:
		combo += 1
	
	consecutive_misses = 0
	
	var note_diff:float = (note.hit_time - Conductor.position) / Conductor.rate
	var judgement:Timings.Judgement = Timings.get_judgement(note_diff)
	
	var receptor:Receptor = note.strum_line.receptors.get_child(note.direction)
	
	for character in note.strum_line.characters:
		character = character as Character
		if not character.is_animated or not character.can_sing:
			continue
		
		character.hold_timer = 0.0
		character.play_anim("sing%s" % StrumLine.NoteDirection.keys()[note.direction])
	
	if judgement.do_splash:
		do_splash(receptor, note)
	
	note.was_already_hit = true
	note.sprite.visible = false
	
	if note.length <= 0:
		note.queue_free()
	else:
		note.length += note_diff * Conductor.rate
	
	var pain:float = judgement.health_mult
	pain *= note.health_gain_mult * (-1 if judgement.health_mult < 0 else 1)
	health += (event.health_gain if event != null else 0.023) * pain
	
	score += judgement.score
	accuracy_total_hit += judgement.accuracy_mult
	accuracy_hit_notes += 1
	
	if note.display_combo_on_hit:
		pop_up_score(judgement, combo, note_diff < 0.0)
	
	update_score_text()
	
func update_health_bar():
	var opponent_icon:Sprite2D = character_icons.get_child(0) as Sprite2D
	var player_icon:Sprite2D = character_icons.get_child(1) as Sprite2D
	
	opponent_icon.texture = opponent.health_icon
	opponent_icon.hframes = opponent.health_icon_frames
	
	var o:StyleBoxFlat = health_bar.get_theme_stylebox("background") as StyleBoxFlat
	o.bg_color = opponent.health_color
	health_bar.add_theme_stylebox_override("background", o)
	
	var p:StyleBoxFlat = health_bar.get_theme_stylebox("fill") as StyleBoxFlat
	p.bg_color = player.health_color
	health_bar.add_theme_stylebox_override("fill", o)
	
func start_song():
	var event := CancellableEvent.new()
	call_on_modcharts("on_start_song", [event])
	
	starting_song = false
	
	for track in tracks:
		track.play()
		
	call_on_modcharts("on_start_song_post", [event])
	
func end_song():
	var event := CancellableEvent.new()
	call_on_modcharts("on_end_song", [event])
	
	if not event.cancelled:
		ending_song = false
		match GAME_MODE:
			GameMode.STORY: Global.switch_scene("res://scenes/menus/StoryMenu.tscn")
			GameMode.FREEPLAY: Global.switch_scene("res://scenes/menus/FreeplayMenu.tscn")
	
	call_on_modcharts("on_end_song_post", [event])
	event.unreference()
	
func _process_event(name:String, parameters:PackedStringArray, time:float = -INF):
	match name:
		"Camera Pan": 
			cur_camera_target = 1 if parameters[0].to_lower() == "true" else 0
			
			# lord save my soul for what i have done
			var focused_strum_line:StrumLine = strum_lines.get_child(cur_camera_target) as StrumLine
			var final_cam_pos:Vector2 = Vector2(0, 0)
			var cameramatical_pain:int = 0
			
			for character in focused_strum_line.characters:
				character = character as Character
				final_cam_pos += character.get_camera_pos()
				cameramatical_pain += 1
				
			final_cam_pos /= cameramatical_pain
			camera.position = final_cam_pos
			
		"BPM Change": 
			pass # handled by conductor
			
		_:
			if not name in _loaded_events:
				printerr("Tried to run non-existent event: %s" % name)
				return
			
			var event:Modchart = _loaded_events[name]
			if not is_instance_valid(event):
				return
			
			event.call_method("on_event", parameters)
			call_on_modcharts("on_event", parameters)
			
			event.queue_free()
		
func _physics_process(delta:float):
	call_deferred_thread_group("do_note_spawning")
	
	for group in CHART.events:
		if group.time > Conductor.position:
			break
			
		for event in group.events:
			_process_event(event.name, event.parameters, group.time)
			
		CHART.events.erase(group)
	
	for strum_line in strum_lines.get_children():
		for character in strum_line.characters:
			character = character as Character
			if not character._is_true_player or character.hold_timer < Conductor.step_crochet * character.sing_duration * 0.0011 or strum_line.keys_pressed.has(true):
				continue
			
			character.hold_timer = 0.0
			character.dance()
			
	call_on_modcharts("_physics_process_post", [delta])

func _process(delta:float):
	delta = minf(delta, 0.1)
	
	Conductor.position += delta * 1000.0
	if Conductor.position >= 0.0 and starting_song:
		start_song()
		
	# makes sure each track is up to date with conductor rate
	for track in tracks:
		track.pitch_scale = Conductor.rate
	
	if not finished_tracks.has(false):
		end_song()
		
	if cam_zooming:
		camera.zoom = camera.zoom.lerp(Vector2(default_cam_zoom, default_cam_zoom), delta * 3.0)
		hud.scale = hud.scale.lerp(Vector2.ONE, delta * 3.0)
		
	var cube_out:Callable = func(t:float): 
		t -= 1.0
		return 1.0 + t * t * t
		
	var zoom:float = lerpf(1.2, 1.0, cube_out.call(fmod(Conductor.cur_dec_beat, 1.0)))
	character_icons.scale = Vector2.ONE if starting_song else Vector2(zoom, zoom)
	character_icons.position.x = health_bar.size.x * (1.0 - (health_bar.value / health_bar.max_value))
	
	call_on_modcharts("_process_post", [delta])
	
func _unhandled_key_input(event):
	event = event as InputEventKey
	
	if OS.is_debug_build():
		match event.keycode:
			KEY_F2:
				skip_time(Conductor.position - 5000.0)
				
			KEY_F3:
				skip_time(Conductor.position + 5000.0)
				
			KEY_F9:
				Global.switch_scene("res://scenes/menus/FreeplayMenu.tscn")

func skip_time(new_time:float):
	var old_time:float = Conductor.position
	Conductor.position = new_time
	
	if new_time > old_time:
		while notes_to_spawn.size() > 0:
			if notes_to_spawn[0].hit_time >= new_time + 500.0:
				break
			
			notes_to_spawn.pop_front()
				
			for strum_line in strum_lines.get_children():
				var note_group:NoteGroup = strum_line.notes
				if note_group.get_child_count() > 0:
					var c:Note = note_group.get_child(0)
					c.queue_free()
					note_group.remove_child(c)	
	else:
		load_notes(new_time + 500.0)
		
	resync_tracks()
	
var countdown_tween:Tween
var cur_countdown_tick:int = 0

func countdown_tick(tick:int = 0):
	var textures:Array[CompressedTexture2D] = [ui_style.prepare_texture, ui_style.ready_texture, ui_style.set_texture, ui_style.go_texture]
	var sounds:Array[AudioStream] = [ui_style.prepare_sound, ui_style.ready_sound, ui_style.set_sound, ui_style.go_sound]

	if countdown_tween != null:
		countdown_tween.kill()
		countdown_tween.unreference()
		
	countdown_tween = create_tween()
	countdown_tween.pause()
	
	# prevent errors
	if tick > sounds.size() - 1: return
	
	var sound := AudioStreamPlayer.new()
	sound.stream = sounds[tick]
		
	var event := CountdownEvent.new(tick, countdown_sprite, sound, countdown_tween)
	call_on_modcharts("on_countdown_tick", [event])
	
	if not event.cancelled:
		if not event.tween.is_running():
			event.tween.play()
		
		event.sprite.texture = textures[tick]
		event.sprite.modulate.a = 1.0
		event.tween.set_ease(Tween.EASE_IN_OUT)
		event.tween.set_trans(Tween.TRANS_CUBIC)
		event.tween.tween_property(event.sprite, "modulate:a", 0.0, Conductor.crochet / 1000.0)
		
		add_child(event.sound)
		event.sound.play()
		
	call_on_modcharts("on_countdown_tick_post", [event])
	event.unreference()

func _beat_hit(beat:int):
	if starting_song:
		countdown_tick(cur_countdown_tick)
		cur_countdown_tick += 1
	elif beat > 0 and cam_zooming_interval > 0 and beat % cam_zooming_interval == 0:
		camera.zoom += Vector2(0.015, 0.015)
		hud.scale += Vector2(0.03, 0.03)
		
	for strum_line in strum_lines.get_children():
		for character in strum_line.characters:
			character = character as Character
			if character.last_anim.begins_with("sing"):
				continue
				
			character.dance()
		
	call_on_modcharts("_beat_hit", [beat])
		
func _step_hit(step:int):
	if not starting_song and not ending_song:
		for track in tracks:
			if not is_track_synced(track):
				resync_tracks()
				break
	
	call_on_modcharts("_step_hit", [step])
			
func _measure_hit(measure:int):
	call_on_modcharts("_measure_hit", [measure])
	call_on_modcharts("_section_hit", [measure])

func resync_tracks():
	var event := CancellableEvent.new()
	call_on_modcharts("on_resync_tracks", [event])
	call_on_modcharts("on_resync_music", [event])
	call_on_modcharts("on_resync_song", [event])
	call_on_modcharts("on_resync_vocals", [event])
	
	if not event.cancelled:
		for _track in tracks:
			_track.seek(Conductor.position * 0.001)
			
	event.unreference()
		
func _get_note_speed(note:Chart.ChartNote):
	var strum_line:StrumLine = strum_lines.get_child(note.strum_index)
	
	if strum_line.scroll_speed != -INF:
		return strum_line.scroll_speed / Conductor.rate
		
	if scroll_speed != -INF:
		return scroll_speed / Conductor.rate
			
	return CHART.scroll_speed / Conductor.rate
