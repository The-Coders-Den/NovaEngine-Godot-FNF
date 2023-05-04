extends Event
func _ready():
	print(parameters)
	if parameters.size() != 2:
		parameters.resize(2)
		if parameters[0]: parameters[0] = "0.015"
		if parameters[1]: parameters[1] = "0.03"
	game.camera.zoom += Vector2(float(parameters[0]),float(parameters[0]))
	game.hud.scale += Vector2(float(parameters[1]),float(parameters[1]))
	game.position_hud()
	queue_free()
