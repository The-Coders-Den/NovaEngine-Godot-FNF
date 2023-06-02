class_name BPMChangeEvent extends Resource

var step:float = 0
var time:float = 0.0
var bpm:float = 100.0

func _init(step:float = 0, time:float = 0, bpm:float = 0):
	self.step = step
	self.time = time
	self.bpm = bpm
