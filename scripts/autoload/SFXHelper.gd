extends Node

const VOLUME_UP := preload("res://assets/engine/sounds/pop.ogg")
const VOLUME_DOWN := preload("res://assets/engine/sounds/pop.ogg")

func play(audio:AudioStream):
	var player := AudioStreamPlayer.new()
	player.stream = audio
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()
