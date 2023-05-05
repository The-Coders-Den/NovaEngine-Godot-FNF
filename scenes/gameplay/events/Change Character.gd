extends Event

var character:String = "dad"

func _ready() -> void:
	match parameters[0]:
		"0", "bf": character = "bf"
		"1", "dad": character = "dad"
		"2", "gf": character = "gf"
	
	change_char()

func change_char() -> void:
	var old_character:Character
	var new_character:Character = load("res://scenes/gameplay/characters/" + parameters[1] + ".tscn").instantiate()
	
	if character == "bf":
		new_character._is_true_player = true
	
	game.remove_child(old_character)
	game.add_child(new_character)
	
	match character:
		"dad":
			old_character = game.opponent
			new_character.position = old_character.position
			game.opponent = new_character
			game.cpu_icon.texture = new_character.health_icon
			game.cpu_icon.hframes = new_character.health_icon_frames
			game.OPPONENT_HEALTH_COLOR.bg_color = new_character.health_color
		"bf":
			old_character = game.player
			new_character.position = old_character.position
			game.player = new_character
			game.player_icon.texture = new_character.health_icon
			game.player_icon.hframes = new_character.health_icon_frames
			game.PLAYER_HEALTH_COLOR.bg_color = new_character.health_color
		"gf":
			old_character = game.spectator
			new_character.position = old_character.position
			game.spectator = new_character
	
	old_character.queue_free()
	queue_free()
