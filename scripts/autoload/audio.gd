extends Node
const MENU_SOUNDS = {"SCROLL" : "menus/scrollMenu","CANCEL": "menus/cancelMenu","CONFIRM" : "menus/confirmMenu"}
@onready var sound = $sound
@onready var music = $music
func play_sound(path:String,pitch:float=1.0):
	path = "res://assets/sounds/%s.ogg" % path
	if ResourceLoader.exists(path):
		sound.stream = load(path)
		sound.pitch_scale = pitch
		sound.stream.loop = false
		sound.play()
	else:
		printerr("RESOURCE NOT FOUND %s"  % path)
		
func play_music(path:String,pitch:float=1.0):
	path = "res://assets/music/%s.ogg" % path
	if ResourceLoader.exists(path):
		var stream:AudioStream = load(path)
		if stream == music.stream and music.playing:
			print("OAIKSJDF")
			return
		music.stream = stream
		music.pitch_scale = pitch
		music.play()
	else:
		printerr("RESOURCE NOT FOUND %s"  % path)
