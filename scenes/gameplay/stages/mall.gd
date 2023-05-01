extends Stage
	
@onready var da_boppers = [$"PB/0-33/UpperBop", $"PB/0-9/BottomBop", $"PB/1-0/Santa"]
	
func on_beat_hit(beat:int):
	for bopper in da_boppers:
		bopper.anim_player.seek(0.0)
		bopper.frame = 0
		bopper.anim_player.play("bop")
