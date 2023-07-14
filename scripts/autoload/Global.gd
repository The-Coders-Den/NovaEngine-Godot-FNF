extends Node

var VERSION:VersionScheme = VersionScheme.new(2, 0, 0, VersionScheme.VersionType.DEV)

func switch_scene(path:String):
	get_tree().change_scene_to_file(path)
	
func _unhandled_key_input(event:InputEvent):
	if Input.is_action_just_pressed("fullscreen"):
		var win:Window = get_window()
		if win.mode == Window.MODE_FULLSCREEN:
			win.mode = Window.MODE_WINDOWED
		else:
			win.mode = Window.MODE_FULLSCREEN
