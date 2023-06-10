class_name Gameplay extends Node2D

@onready var opponent_strums := $HUDContainer/HUD/OpponentStrums
@onready var player_strums := $HUDContainer/HUD/PlayerStrums

var scroll_speed:float = -INF

func _ready():
	Global.CHART = Chart.load_song("fresh", "hard", Chart.ChartType.FNF)
	Conductor.setup_song(Global.CHART)
	Conductor.position = Conductor.crochet * -5
	
	var note_spawner := NoteSpawner.new()
	note_spawner.connect_strumline(opponent_strums)
	note_spawner.connect_strumline(player_strums)
	add_child(note_spawner)

func _process(delta:float):
	Conductor.position += delta * 1000.0
