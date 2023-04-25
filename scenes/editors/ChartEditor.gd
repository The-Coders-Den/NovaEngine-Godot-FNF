extends Control
@onready var inst = $sounds/inst
@onready var voices = $sounds/voices
@onready var hitsound = $sounds/hitsound

@onready var player_lane = $"GridContainer/player Lane"
@onready var oppnent_lane = $"GridContainer/oppnent lane"
@onready var oppnent_strum = $"GridContainer/oppnent lane/Oppnent Strum"
@onready var player_strum = $"GridContainer/player Lane/player Strum"

var _notes:Array[SectionNote] = []

var chart_data:Chart = Global.SONG
func _ready():
	if chart_data == null:
		chart_data = Chart.load_chart("dad battle","hard")
		Global.SONG = chart_data
	
	for sec in chart_data.sections:
		for note in sec.notes:
			_notes.push_front(note)
	_notes.sort_custom(func(a, b): return a.time < b.time)
	

func _input(event):
	pass

func play_song():
	if !inst.playing:
		inst.play(Conductor.position/1000)
		voices.play(Conductor.position/1000)
	else:
		inst.stop()
		voices.stop()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		play_song()
	
	if inst.playing:
		Conductor.position = inst.get_playback_position()*1000
