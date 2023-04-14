extends Node2D

func _ready():
	print(ModManager.list_all_mods())
	
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Audio.play_sound("cancelMenu")
		Global.switch_scene("res://scenes/FreeplayMenu.tscn")
