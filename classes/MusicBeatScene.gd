extends Node2D
class_name MusicBeatScene

func _ready() -> void:
	Conductor.connect("beat_hit", beat_hit)
	Conductor.connect("step_hit", step_hit)
	Conductor.connect("section_hit", section_hit)
	
func beat_hit(beat:int) -> void:
	pass
	
func step_hit(step:int) -> void:
	pass

func section_hit(section:int) -> void:
	pass
