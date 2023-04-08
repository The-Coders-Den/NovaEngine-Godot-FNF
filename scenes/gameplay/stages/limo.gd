extends Stage
@onready var dancey_group = $PB/PL2/limo/dancey_group

func _ready():
	$PB/PL2/limo.play("background limo pink")
	$limo.play("Limo stage")
func _ready_post():
	game.spectator.z_as_relative = true
	game.spectator.z_index = -1
	game.player.z_index = 1
	game.opponent.z_index = 1
func on_countdown_tick(a,b):
	for dancey_boy in dancey_group.get_children():
		dancey_boy.dance(0)
