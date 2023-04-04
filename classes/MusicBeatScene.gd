extends Node2D
class_name MusicBeatScene

func _ready():
	Conductor.connect("beat_hit", func(b): _beat_hit(b))
	Conductor.connect("step_hit", func(s): _step_hit(s))
	
func _beat_hit(beat:int):
	pass
	
func _step_hit(step:int):
	pass
