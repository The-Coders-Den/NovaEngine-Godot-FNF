class_name Gameplay extends Node2D

@onready var opponent_strums:StrumLine = $HUDContainer/HUD/OpponentStrums
@onready var player_strums:StrumLine = $HUDContainer/HUD/PlayerStrums

@onready var countdown_sprite:Sprite2D = $HUDContainer/HUD/CountdownSprite

@onready var opponent_group:CharacterGroup = $OpponentGroup
@onready var spectator_group:CharacterGroup = $SpectatorGroup
@onready var player_group:CharacterGroup = $PlayerGroup

@onready var hud:Node2D = $HUDContainer/HUD
@onready var tracks:Node = $Tracks

var note_spawner:NoteSpawner
var scroll_speed:float = -INF
var starting_song:bool = true
var ending_song:bool = false

func load_chart():
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
	
func step_hit(step:int):
	pass
	
func measure_hit(step:int):
	for track in tracks.get_children():
		track = track as AudioStreamPlayer
		if absf((track.get_playback_position() * 1000.0) - Conductor.position) >= 20:
			resync_tracks()
