extends Modchart

func on_event(arg1, arg2):
	print(arg1)
	print(arg2)
	
	game.camera.zoom += Vector2.ONE * 5 # godot moment
