class_name SFXHelper extends Node

static var VOLUME_UP := preload("res://assets/sounds/engine/pop.ogg")
static var VOLUME_DOWN := preload("res://assets/sounds/engine/pop.ogg")

static func play(audio:AudioStream, volume:float = 1.0):
	var player := AudioStreamPlayer.new()
	player.stream = audio
	player.finished.connect(player.queue_free)
	player.volume_db = linear_to_db(volume)
	Overlay.add_child(player)
	player.play()
