extends Label
@onready var game:Gameplay = $"../../"
var song_length:float = INF
var song_time:float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	size.x = Global.game_size.x
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	modulate.a = 0.0
	if SettingsAPI.get_setting("downscroll"):
		position.y = 720 - (position.y + size.y)
	pass # Replace with function body.
	
func intro():
	var tween_in := create_tween()
	tween_in.tween_property(self,"modulate:a",1.0,Conductor.crochet/1000.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	assert(!game.tracks.is_empty())
	song_length = game.tracks[0].stream.get_length()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if modulate.a <= 0.0:
		return
	song_time = Conductor.position
	text = "%s - %s / %s" %[game.SONG.name,Global.format_time(song_time/1000.0),Global.format_time(song_length)]
	pass
