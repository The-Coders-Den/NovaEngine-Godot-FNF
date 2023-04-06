extends Node2D
class_name MusicBeatScene

func _ready():
	Conductor.connect("beat_hit", func(b): beat_hit(b))
	Conductor.connect("step_hit", func(s): step_hit(s))
	
func beat_hit(beat:int):
	pass
	
func step_hit(step:int):
	pass
