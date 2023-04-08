extends Stage
@onready var bg = $PB/AnimatedSprite
@onready var icon = $Icon

func _ready():
	Conductor.beat_hit.connect(beat_hit)
	if randf_range(0,100) < 0.1:
		icon.visible = true
	else:
		icon.visible = false
	
var lightningStrikeBeat:int = 0
var lightningOffset:int = randi_range(8,24)
func beat_hit(beat:int):
	if randf_range(0,100) < 10.0 and beat > lightningStrikeBeat + lightningOffset:
		Audio.play_sound("stages/spooky/thunder" + str(randi_range(1,2)))
		game.player.play_anim("scared",true)
		game.player.special_anim = true
		game.player.anim_timer = 1.0
		game.spectator.play_anim("scared",true)
		game.spectator.special_anim = true
		game.spectator.anim_timer = 1.0
		lightningStrikeBeat = beat
		bg.frame = 0
		bg.play("halloweem bg lightning strike")
