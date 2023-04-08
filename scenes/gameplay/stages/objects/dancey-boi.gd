extends AnimatedSprite
@onready var animation_player = $AnimationPlayer
func _ready():
	Conductor.beat_hit.connect(dance)
var danced:bool = false

func dance(beat:int):
	if danced:
		animation_player.play("danceRight")
	else:
		animation_player.play("danceLeft")
	danced = !danced
