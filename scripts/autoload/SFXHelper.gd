extends Node

const VOLUME_UP := preload("res://assets/engine/sounds/pop.ogg")
const VOLUME_DOWN := preload("res://assets/engine/sounds/pop.ogg")

func play(audio:AudioStream, volume:float = 1.0):
	var player := AudioStreamPlayer.new()
	player.stream = audio
	player.finished.connect(player.queue_free)
	player.volume_db = linear_to_db(volume)
	add_child(player)
	player.play()
