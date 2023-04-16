extends Node2D

func _ready():
	await get_tree().create_timer(0.1).timeout
	Global.switch_scene(Global.last_scene_path)
