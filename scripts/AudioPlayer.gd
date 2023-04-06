extends AudioStreamPlayer
class_name AudioPlayer

var time:float:
	set(v):
		seek(v / 1000.0)
	get:
		return get_playback_position() * 1000.0
