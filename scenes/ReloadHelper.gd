extends Node2D

# this is for making the mods menu work correctly
# please do not change this

func _ready():
	await get_tree().create_timer(0.1).timeout
	Global.switch_scene(Global.last_scene_path)
