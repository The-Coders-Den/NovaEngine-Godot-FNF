extends Node2D

func _ready() -> void:
	ModManager._ready()
	ModManager.switch_mod(SettingsAPI.get_setting("current mod"))
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
