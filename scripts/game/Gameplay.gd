class_name Gameplay extends Node2D

@onready var opponent_strums:StrumLine = $HUDContainer/HUD/OpponentStrums
@onready var player_strums:StrumLine = $HUDContainer/HUD/PlayerStrums

@onready var countdown_sprite:Sprite2D = $HUDContainer/HUD/CountdownSprite

@onready var opponent_group:CharacterGroup = $OpponentGroup
@onready var spectator_group:CharacterGroup = $SpectatorGroup
@onready var player_group:CharacterGroup = $PlayerGroup

@onready var hud:Node2D = $HUDContainer/HUD
@onready var tracks:Node = $Tracks

@onready var rating_template:Node2D = $"HUDContainer/Rating Template"
@onready var icons:Node2D = $HUDContainer/HUD/HealthBar/Icons

@onready var score_text:Label = $HUDContainer/HUD/HealthBar/ScoreText
@onready var ms_text:Label = $HUDContainer/HUD/MSText

var RATING_TIMES:Dictionary = {
	"sick": 45.0,
	"good": 90.0,
	"bad":  135.0,
	"shit": 180.0
}

var rating_textures:Dictionary = {}
var combo_textures:Dictionary = {}

var hit_times:Array[float] = []
var avg_ms:float:
	get:
		var num:float = 0
		for time in hit_times:
			num += time
		return num / hit_times.size()-1
		
var combo_streaks:int = 0
var score:int = 0
var combo:int = 0
var misses:int = 0

var note_spawner:NoteSpawner
var scroll_speed:float = -INF
var starting_song:bool = true
var ending_song:bool = false

var note_style:NoteStyle
var ui_style:UIStyle

func load_chart():
	Global.SONG_NAME = "breakout"
	Global.SONG_DIFFICULTY = "hard"
	Global.CHART = Chart.load_song(Global.SONG_NAME, Global.SONG_DIFFICULTY, Chart.ChartType.FNF)
	Conductor.setup_song(Global.CHART)
	Conductor.position = Conductor.crochet * -5
	
func load_styles():
	note_style = load("res://assets/funkin/data/notestyles/%s.tres" % Global.CHART.note_style)
	ui_style = load("res://assets/funkin/data/uistyles/%s.tres" % Global.CHART.ui_style)
	
func load_tracks():
	var dir := DirAccess.open("res://assets/funkin/songs/%s/audio" % Global.SONG_NAME.to_lower())
	for file in dir.get_files():
		var is_valid:bool = false
		
		for ext in Paths.AUDIO_EXTS:
			if file.ends_with("%s.import" % ext):
				is_valid = true
				break
		
		if not is_valid: continue
		
		var track := AudioStreamPlayer.new()
		track.stream = load("res://assets/funkin/songs/%s/audio/%s" % [Global.SONG_NAME.to_lower(), file.replace(".import", "")])
		track.pitch_scale = Conductor.rate
		tracks.add_child(track)
		
	Engine.time_scale = Conductor.rate
		
func load_textures():
	for shit in RATING_TIMES.keys():
		rating_textures[shit] = load("%s/%s.png" % [ui_style.rating_texture_folder, shit])
		
	for num in 10:
		combo_textures[str(num)] = load("%s/num%s.png" % [ui_style.combo_texture_folder, str(num)])
		
func setup_note_spawner():
	note_spawner = NoteSpawner.new()
	note_spawner.connect_strumline(opponent_strums)
	note_spawner.connect_strumline(player_strums)
	add_child(note_spawner)
	
func setup_conductor():
	Conductor.beat_hit.connect(beat_hit)
	Conductor.step_hit.connect(step_hit)
	Conductor.measure_hit.connect(measure_hit)
		
func start_song():
	starting_song = false
	Conductor.position = 0.0
	for track in tracks.get_children():
		track = track as AudioStreamPlayer
		track.play()
		
func resync_tracks():
	for track in tracks.get_children():
		track = track as AudioStreamPlayer
		track.seek(Conductor.position / 1000.0)

func _ready():
	load_chart()
	load_styles()
	load_tracks()
	load_textures()
	setup_note_spawner()
	setup_conductor()
	update_score_text()
	
func _unhandled_key_input(event):
	event = event as InputEventKey
	if not OS.is_debug_build(): return
	
	match event.keycode:
		KEY_F3:
			Conductor.position += 10000
			resync_tracks()

func _process(delta:float):
	Conductor.position += delta * 1000.0

	if starting_song and Conductor.position >= 0.0:
		start_song()
		
	var big_fart:float = lerpf(1.2, 1.0, Global.EASE_FUNCS.cube_out.call(fmod(Conductor.cur_dec_beat, 1.0))) if not starting_song else 1.0
	icons.scale = Vector2(big_fart, big_fart)
	
	hud.scale = lerp(hud.scale, Vector2.ONE, clampf(delta * 3.0, 0.0, 1.0))

func beat_hit(beat:int):
	if starting_song:
		countdown_tick(absi(beat))
		return
	
	if beat > 0 and fmod(beat, Conductor.beats_per_measure) == 0:
		hud.scale += Vector2(0.03, 0.03)
		
var countdown_tween:Tween
		
func countdown_tick(tick:int):
	tick = 4 - tick
	if tick < 0: return
	
	if countdown_tween:
		countdown_tween.stop()
	
	var images:Array[CompressedTexture2D] = [
		ui_style.prepare_texture,
		ui_style.ready_texture,
		ui_style.set_texture,
		ui_style.go_texture
	]
	var sounds:Array[AudioStream] = [
		ui_style.prepare_sound,
		ui_style.ready_sound,
		ui_style.set_sound,
		ui_style.go_sound
	]
	SFXHelper.play(sounds[tick])
	
	countdown_sprite.texture = images[tick]
	countdown_sprite.visible = true
	countdown_sprite.modulate.a = 1.0
	
	countdown_tween = create_tween()
	countdown_tween.set_ease(Tween.EASE_IN_OUT)
	countdown_tween.set_trans(Tween.TRANS_CUBIC)
	countdown_tween.tween_property(countdown_sprite, "modulate:a", 0.0, Conductor.crochet / 1000.0)
	
func good_note_hit(note:Note):
	note.remove_child(note.splash)
	note.strumline.add_child(note.splash)
	pop_up_score(note)
	note.queue_free()
	
func pop_up_score(note:Note):
	combo += 1
	var combo_split:PackedStringArray = str(combo).pad_zeros(3).split("")
	var hit_diff:float = absf(note.time - Conductor.position) / Conductor.rate
	hit_times.append((note.time - Conductor.position) / Conductor.rate)
	
	if combo % 10 == 0:
		combo_streaks += 1
		
	ms_text.text = "Avg MS: %.2fms" % avg_ms
	ms_text.text += "\nCombo Streaks: %s" % combo_streaks
	
	update_score_text()
	
	var rating:String = RATING_TIMES.keys()[RATING_TIMES.keys().size()-1]
	for time in RATING_TIMES.values():
		if hit_diff <= time:
			rating = RATING_TIMES.find_key(time)
			break
			
	var ratingcopy:Node2D = rating_template.duplicate()
	add_child(ratingcopy)
	var rating_sprite:Sprite2D = ratingcopy.get_node("rating") as Sprite2D
	ratingcopy.visible = true
	ratingcopy.modulate.a = 1.0
	rating_sprite.scale = Vector2(0.9,0.9)
	rating_sprite.texture = rating_textures[rating]
	rating_sprite.process_mode = Node.PROCESS_MODE_DISABLED
	create_tween().tween_property(rating_sprite,"scale",Vector2(0.7,0.7),0.5*Conductor.crochet/1000).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var i:int = 0
	for num in combo_split:
		var num_sprite:Sprite2D = Sprite2D.new()
		num_sprite.texture = combo_textures[num]
		num_sprite.position.y += 75
		num_sprite.position.x = rating_sprite.position.x - 22.5 * combo_split.size() + 50 * i
		num_sprite.scale *= 0.7
		num_sprite.process_mode = Node.PROCESS_MODE_DISABLED
		ratingcopy.add_child(num_sprite)
		
		create_tween().tween_property(num_sprite,"scale",Vector2(0.5,0.5),0.25*Conductor.crochet/1000).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		i += 1
		
	create_tween().tween_property(ratingcopy,"modulate:a",0,Conductor.crochet/1000).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).finished.connect(ratingcopy.queue_free)
	
	if rating == "sick":
		note.splash.visible = true
		note.splash.position = note.strumline.receptors.get_child(note.direction).position
		note.splash.play("%s%s" % [Global.dir_to_str(note.direction), str(randi_range(1, 2))])
		note.splash.animation_finished.connect(note.splash.queue_free)

func fake_miss(direction:int, note:Note = null):
	combo = 0
	misses += 1
	update_score_text()
	
	if is_instance_valid(note):
		note.queue_free()

func update_score_text():
	score_text.text = "Score: %s" % score
	score_text.text += " • Accuracy: %.2f" % calculate_accuracy()
	score_text.text += "%"
	score_text.text += " • Combo Breaks: %s" % misses
	
func calculate_accuracy() -> float:
	var acc:float = 0.0
	return acc

func step_hit(step:int):
	pass
	
func measure_hit(step:int):
	for track in tracks.get_children():
		track = track as AudioStreamPlayer
		if absf((track.get_playback_position() * 1000.0) - Conductor.position) >= 20:
			resync_tracks()
