extends MusicBeatScene

@onready var gf = $gf/AnimationPlayer
@onready var logo = $logo

func _ready():
	super._ready()
	
	Conductor.change_bpm(102.0)
	gf.play("danceLeft")
	logo.play("logo bumpin")

func _process(delta):
	Conductor.position += delta * 1000.0

func _beat_hit(beat:int):
	logo.frame = 0
	logo.play("logo bumpin")
	
	gf.play("danceLeft" if beat % 2 == 0 else "danceRight")
