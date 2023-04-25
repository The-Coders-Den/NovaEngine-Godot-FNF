extends Note

func _ready():
	super._ready()

func _player_hit():
	game.health -= game.max_health/8
