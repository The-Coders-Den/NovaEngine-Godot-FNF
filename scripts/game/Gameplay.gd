class_name Gameplay extends Node2D

#-- statics --#
static var CHART:Chart

#-- normals --#
@onready var camera:Camera2D = $Camera2D
@onready var hud:Node2D = $HUDContainer/HUD

@onready var strum_lines:Node2D = $HUDContainer/HUD/StrumLines
@onready var opponent_strums:StrumLine = $HUDContainer/HUD/StrumLines/OpponentStrums
@onready var player_strums:StrumLine = $HUDContainer/HUD/StrumLines/PlayerStrums

@onready var health_bar:ProgressBar = $HUDContainer/HUD/HealthBar
@onready var character_icons:Node2D = $HUDContainer/HUD/HealthBar/Icons
@onready var score_text:Label = $HUDContainer/HUD/HealthBar/ScoreText

var template_notes:Dictionary = {
	"default": preload("res://scenes/game/notes/Default.tscn").instantiate()
}

var tracks:Array[AudioStreamPlayer] = []
var notes_to_spawn:Array[Chart.ChartNote] = []

var scroll_speed:float = -INF
var starting_song:bool = true
var ending_song:bool = false

var modcharts:Array[Modchart] = []

var score:int = 0
var misses:int = 0
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
		
var cam_zooming:bool = true
var cam_zooming_interval:int = 4

var accuracy_total_hit:float = 0.0
var accuracy_hit_notes:int = 0

var consecutive_misses:float = 0.0

var combo:int = 0

func load_tracks():
	var base_path:String = "res://assets/songs/%s/music" % CHART.song_name
	for shit in DirAccess.open(base_path).get_files():
		if not shit.ends_with(".import"):
			continue
			
		var track := AudioStreamPlayer.new()
		track.stream = load("%s/%s" % [base_path, shit.replace(".import", "")])
		track.pitch_scale = Conductor.rate
		tracks.append(track)
		add_child(track)
		
func call_on_modcharts(method:String, args:Array[Variant]):
	for modchart in modcharts:
		if not is_instance_valid(modchart):
			continue
			
		modchart.call_method(method, args)
		
func load_modcharts():
	# Setup signals
	Signals.on_note_hit.connect(func(e): call_on_modcharts("on_note_hit", [e]))
	Signals.on_note_miss.connect(func(e): call_on_modcharts("on_note_miss", [e]))
	Signals.on_resync_tracks.connect(func(e): call_on_modcharts("on_resync_tracks", [e]))
	Signals.on_update_score_text.connect(func(e): call_on_modcharts("on_update_score_text", [e]))
	
	# Song specific and global
	for script_path in [
		"res://assets/songs/%s/modcharts/" % CHART.song_name,
		"res://assets/modcharts/"
	]:
		if not DirAccess.dir_exists_absolute(script_path):
			continue
		
		for item in DirAccess.open(script_path).get_files():
			if item.ends_with(".tscn") or item.ends_with(".tscn.remap"):
				var modchart:Modchart = load(script_path+item.replace(".remap", "")).instantiate()
				modchart.game = self
				modcharts.append(modchart)
				add_child(modchart)
		
func is_track_synced(track:AudioStreamPlayer):
	# i love windows
	var ms_allowed:float = (30 if OS.get_name() == "Windows" else 20) * track.pitch_scale
	var track_time:float = track.get_playback_position() * 1000.0
	return !(absf(track_time - Conductor.position) > ms_allowed)

func update_score_text():
	var event := CancellableEvent.new()
	Signals.on_update_score_text.emit(event)
	
	if event.cancelled: return
	
	var sep:String = " • "
	score_text.text = "< "
	score_text.text += "Score: %s" % str(score)
	score_text.text += "%sAccuracy: %.2f%s" % [sep, accuracy * 100.0, "%"]
	score_text.text += "%sCombo Breaks: %s" % [sep, str(misses)]
	score_text.text += "%sRank: %s" % [sep, Timings.get_rank(accuracy * 100.0).name]
	score_text.text += " >"

func _ready():
	var old:float = Time.get_ticks_msec()
	CHART = Chart.load_chart("amusia", "hard")
	print("Chart parse time: %s ms" % str(Time.get_ticks_msec() - old))
	
	# prepare song
	Conductor.setup_song(CHART)
	Conductor.position = Conductor.crochet * -5
	cam_zooming_interval = Conductor.beats_per_measure
	
	# load chart notes & music
	for note in CHART.notes:
		var new_note:Chart.ChartNote = note.duplicate(true)
		notes_to_spawn.append(new_note)
		
	notes_to_spawn.sort_custom(func(a:Chart.ChartNote, b:Chart.ChartNote): return a.hit_time < b.hit_time)
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
	
var _note_spawn_timer:float = 0.0
	
func do_note_spawning():
	_note_spawn_timer += get_process_delta_time()
	
	var radius:float = (Conductor.crochet / 1000.0) / (CHART.beats_per_measure * CHART.steps_per_beat)
	if _note_spawn_timer < radius:
		return
		
	_note_spawn_timer = 0.0
	for note in notes_to_spawn:
		if note.hit_time > Conductor.position + (2500 / _get_note_speed(note)):
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
		
		splash.animation_finished.connect(func():
			splash.visible = false
			splash.process_mode = Node.PROCESS_MODE_DISABLED
		)
		
func note_miss(direction:int, note:Note = null, event:NoteMissEvent = null):
	combo = 0
	misses += 1
	
	if consecutive_misses == 0:
		consecutive_misses = 1
		
	health -= (event.health_loss if event != null else 0.0475) * consecutive_misses
	consecutive_misses += 0.175
	
	if note != null:
		note.queue_free()
		
	update_score_text()
		
func good_note_hit(note:Note, event:NoteHitEvent = null):
	combo += 1
	consecutive_misses = 0
	
	var note_diff:float = (note.hit_time - Conductor.position) / Conductor.rate
	var judgement:Timings.Judgement = Timings.get_judgement(note_diff)
	
	var receptor:Receptor = note.strum_line.receptors.get_child(note.direction)
	
	if judgement.do_splash:
		do_splash(receptor, note)
	
	note.was_already_hit = true
	note.sprite.visible = false
	
	if note.length <= 0:
		note.queue_free()
	else:
		note.length += note_diff * Conductor.rate
	
	health += (event.health_gain if event != null else 0.023) * judgement.health_mult
	score += judgement.score
	accuracy_total_hit += judgement.accuracy_mult
	accuracy_hit_notes += 1
	update_score_text()
	
func start_song():
	starting_song = false
	
	for track in tracks:
		track.play()
		
func _physics_process(delta:float):
	do_note_spawning()
	
func _process(delta:float):
	Conductor.position += delta * 1000.0
	if Conductor.position >= 0.0 and starting_song:
		start_song()
		
	camera.zoom = camera.zoom.lerp(Vector2.ONE, delta * 3.0)
	hud.scale = hud.scale.lerp(Vector2.ONE, delta * 3.0)
		
	var cube_out:Callable = func(t:float): 
		t -= 1.0
		return 1.0 + t * t * t
		
	var zoom:float = lerpf(1.2, 1.0, cube_out.call(fmod(Conductor.cur_dec_beat, 1.0)))
	character_icons.scale = Vector2.ONE if starting_song else Vector2(zoom, zoom)
	character_icons.position.x = health_bar.size.x * (1.0 - (health_bar.value / health_bar.max_value))
	
func _unhandled_key_input(event):
	event = event as InputEventKey
	
	if OS.is_debug_build():
		match event.keycode:
			KEY_F3:
				Conductor.position += 5000.0
				resync_tracks()
				
			KEY_F9:
				get_tree().change_scene_to_file("res://scenes/menus/FreeplayMenu.tscn")

func _beat_hit(beat:int):
	if not starting_song and beat > 0 and cam_zooming and cam_zooming_interval > 0 and beat % cam_zooming_interval == 0:
		camera.zoom += Vector2(0.015, 0.015)
		hud.scale += Vector2(0.03, 0.03)
		
	call_on_modcharts("_beat_hit", [beat])
		
func _step_hit(step:int):
	if starting_song: return
	for track in tracks:
		if not is_track_synced(track):
			resync_tracks()
			break
			
	call_on_modcharts("_step_hit", [step])
			
func _measure_hit(measure:int):
	call_on_modcharts("_measure_hit", [measure])
	call_on_modcharts("_section_hit", [measure])

func resync_tracks():
	for _track in tracks:
		_track.seek(Conductor.position * 0.001)
		
func _get_note_speed(note:Chart.ChartNote):
	var strum_line:StrumLine = strum_lines.get_child(note.strum_index)
	
	if strum_line.scroll_speed != -INF:
		return strum_line.scroll_speed / Conductor.rate
		
	if scroll_speed != -INF:
		return scroll_speed / Conductor.rate
			
	return CHART.scroll_speed / Conductor.rate
