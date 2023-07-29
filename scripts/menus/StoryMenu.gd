extends Node2D

func _unhandled_key_input(event):
	event = event as InputEventKey
	if not event.is_pressed(): return
		
	if event.is_action_pressed("ui_cancel"):
		Global.switch_scene("res://scenes/menus/MainMenu.tscn")
