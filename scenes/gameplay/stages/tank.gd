extends Stage
@onready var watch_tower:AnimatedSprite2D = $PB/PL6/tank_watch_tower
func _ready():
	Conductor.beat_hit.connect(beat_hit)
	$PB/PL5/smoke_right.play("SmokeRight instance 1")
	$PB/PL5/smoke_left.play("SmokeBlurLeft instance 1")

func beat_hit(beat:int):
	if beat %4 == 0:
		watch_tower.play("watchtower gradient color instance 1")
