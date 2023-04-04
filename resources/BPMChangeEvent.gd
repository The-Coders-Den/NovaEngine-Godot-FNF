extends Resource

class_name BPMChangeEvent

var step_time:int = 0
var song_time:float = 0.0
var bpm:float = 100.0

static func create(step_time:float, song_time:float, bpm:float):
	var instance:BPMChangeEvent = new()
	instance.step_time = step_time
	instance.song_time = song_time
	instance.bpm = bpm
	return instance
