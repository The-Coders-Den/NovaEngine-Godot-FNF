extends Node2D

var cur_music_path:String = "_"

@onready var music:AudioPlayer = $Music
@onready var sounds:Node2D = $Sounds

func play_music(path:String):
	path = "res://assets/music/"+path+".ogg"
	
	if cur_music_path == path: return
	cur_music_path = path
	
	music.stream = load(path)
	music.stream.loop = true
	music.play(0.0)
	
func stop_music():
	cur_music_path = "_"
	music.stop()

func play_sound(path:String):
	var split_path:PackedStringArray = path.replace(".ogg", "").split("/")
	var node_shit:AudioPlayer = get_node_or_null("Sounds/"+split_path[split_path.size()-1])
	
	if node_shit != null:
		node_shit.play(0.0)
	else:
		var player = AudioPlayer.new()
		player.stream = load("res://assets/sounds/"+path+".ogg")
		player.connect("finished", func(): player.queue_free())
		sounds.add_child(player)
