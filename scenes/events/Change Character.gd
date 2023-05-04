extends Event

var char:String = "dad"
var character:Character
var _name:String
func _ready():
	character = game.opponent
	_name = parameters[1]
	match parameters[0]:
		"0": char = "bf"
		"1": char = "dad"
		"2": char = "gf"
		"dad": character = game.opponent
		"bf": character = game.player
		"gf": character = game.spectator
	change_char()

func change_char():
	var new_char:Character = load("res://scenes/gameplay/characters/" + _name + ".tscn").instantiate()
	if char == "bf":
		new_char._is_true_player = true
	new_char.position = character.position
	game.add_child(new_char)
	match char:
		"dad": 
				new_char.position = game.opponent.position
				game.opponent.queue_free()
				game.opponent = new_char
				game.cpu_icon.texture = new_char.health_icon
				game.cpu_icon.hframes = new_char.health_icon_frames
				game.OPPONENT_HEALTH_COLOR.bg_color = new_char.health_color
				
		"bf": 
				new_char.position = game.player.position
				game.player.queue_free()
				game.player = new_char
				game.player_icon.texture = new_char.health_icon
				game.player_icon.hframes = new_char.health_icon_frames
				game.PLAYER_HEALTH_COLOR.bg_color = new_char.health_color
		"gf": 
				new_char.position = game.spectator.position
				game.spectator.queue_free()
				game.spectator = new_char
	queue_free()

