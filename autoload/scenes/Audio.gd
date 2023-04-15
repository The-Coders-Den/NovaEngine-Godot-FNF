extends Node

var cur_music_path:String = "_"

@onready var music:AudioPlayer = $Music
@onready var sounds:Node = $Sounds

func play_music(path:String, volume:float = 1.0):
	path = "res://assets/music/"+path+".ogg"
	
	if cur_music_path == path: return
	cur_music_path = path
	
	music.stream = load(path)
	music.volume_db = linear_to_db(volume)
	music.stream.loop = true
	music.play(0.0)
	
func stop_music():
	cur_music_path = "_"
	music.stop()

func play_sound(path:String, volume:float = 1.0):
	var split_path:PackedStringArray = path.replace(".ogg", "").split("/")
	var node_shit:AudioPlayer = get_node_or_null("Sounds/"+split_path[split_path.size()-1])
	
	if node_shit != null:
		node_shit.play(0.0)
	else:
		var player = AudioPlayer.new()
		player.stream = load("res://assets/sounds/"+path+".ogg")
		player.connect("finished", func(): player.queue_free())
		player.volume_db = linear_to_db(volume)
		sounds.add_child(player)
		
		player.play()
