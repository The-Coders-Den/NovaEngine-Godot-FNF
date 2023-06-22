class_name Gameplay extends Node2D

@onready var opponent_strums:StrumLine = $HUDContainer/HUD/OpponentStrums
@onready var player_strums:StrumLine = $HUDContainer/HUD/PlayerStrums

@onready var countdown_sprite:Sprite2D = $HUDContainer/HUD/CountdownSprite

@onready var opponent_group:CharacterGroup = $OpponentGroup
@onready var spectator_group:CharacterGroup = $SpectatorGroup
@onready var player_group:CharacterGroup = $PlayerGroup

@onready var hud:Node2D = $HUDContainer/HUD
@onready var tracks:Node = $Tracks

var RATING_TIMES:Dictionary = {
	"SICK": 45.0,
	"GOOD": 90.0,
	"BAD": 135.0,
	"SHIT": 180.0
}
@onready var rating_template = $"HUDContainer/Rating Template"

var combo:int = 0

var note_spawner:NoteSpawner
var scroll_speed:float = -INF
var starting_song:bool = true
var ending_song:bool = false

func load_chart():
	var piss:Control = Control.new()
	Global.SONG_NAME = "fill up"
	Global.SONG_DIFFICULTY = "normal"
	Global.CHART = Chart.load_song(Global.SONG_NAME, Global.SONG_DIFFICULTY, Chart.ChartType.FNF)
	Conductor.setup_song(Global.CHART)
	Conductor.position = Conductor.crochet * -5
	
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
	load_tracks()
	setup_note_spawner()
	setup_conductor()

func _process(delta:float):
	Conductor.position += (delta * 1000.0) * Conductor.rate

	if starting_song and Conductor.position >= 0.0:
		start_song()
		
	hud.scale = lerp(hud.scale, Vector2.ONE, clampf(delta * 3.0 * Conductor.rate, 0.0, 1.0))

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
	
	# will prolly be reworked when skins are added
	var images:PackedStringArray = ["prepare", "ready", "set", "go"]
	var sounds:PackedStringArray = ["3", "2", "1", "Go"]
	SFXHelper.play(load("res://assets/funkin/sounds/countdown/default/intro%s.ogg" % sounds[tick]))
	
	countdown_sprite.texture = load("res://assets/funkin/images/gui/countdown/default/%s.png" % images[tick])
	countdown_sprite.visible = true
	countdown_sprite.modulate.a = 1.0
	
	countdown_tween = create_tween()
	countdown_tween.set_ease(Tween.EASE_IN_OUT)
	countdown_tween.set_trans(Tween.TRANS_CUBIC)
	countdown_tween.tween_property(countdown_sprite, "modulate:a", 0.0, (Conductor.crochet / 1000.0) / Conductor.rate)
	
func good_note_hit(note:Note):
	note.remove_child(note.splash)
	note.strumline.add_child(note.splash)
	pop_up_score(note)
	note.queue_free()
	
func pop_up_score(note:Note):
	combo += 1
	var combo_split = str(combo).pad_zeros(3).split("")
	var hit_diff = absf(note.time - Conductor.position)
	
	var rating:String = "SHIT"
	
	for time in RATING_TIMES.values():
		if (hit_diff <= time):
			rating = RATING_TIMES.find_key(time)
			break
	var ratingcopy:Node2D = rating_template.duplicate()
	add_child(ratingcopy)
	var rating_sprite:Sprite2D = ratingcopy.get_node("rating") as Sprite2D
	ratingcopy.visible = true
	ratingcopy.modulate.a = 1.0
	rating_sprite.scale = Vector2(0.9,0.9)
	rating_sprite.texture = load("res://assets/funkin/images/gui/score/default/%s.png"% rating.to_lower())
	create_tween().tween_property(rating_sprite,"scale",Vector2(0.7,0.7),0.5*Conductor.crochet/1000).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var i:int = 0
	for num in combo_split:

		var num_sprite:Sprite2D = Sprite2D.new()
		num_sprite.texture = load("res://assets/funkin/images/gui/score/default/num%s.png"%num)
		
			
		ratingcopy.add_child(num_sprite)
		num_sprite.position.y += 75
		num_sprite.position.x = rating_sprite.position.x - 22.5*combo_split.size() + 50*i
		num_sprite.scale *= 0.7
		create_tween().tween_property(num_sprite,"scale",Vector2(0.5,0.5),0.25*Conductor.crochet/1000).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		i += 1
	create_tween().tween_property(ratingcopy,"modulate:a",0,Conductor.crochet/1000).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).finished.connect(ratingcopy.queue_free)
	if rating == "SICK":
		note.splash.visible = true
		note.splash.position = note.strumline.receptors.get_child(note.direction).position
		note.splash.play("%s%s" % [Global.dir_to_str(note.direction), str(randi_range(1, 2))])
		note.splash.animation_finished.connect(note.splash.queue_free)

func step_hit(step:int):
	pass
	
func measure_hit(step:int):
	for track in tracks.get_children():
		track = track as AudioStreamPlayer
		if absf((track.get_playback_position() * 1000.0) - Conductor.position) >= 20:
			resync_tracks()
