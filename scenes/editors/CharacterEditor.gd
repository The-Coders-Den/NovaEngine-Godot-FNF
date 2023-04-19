extends Node2D

@onready var camera:Camera2D = $Camera2D

func _ready():
	$"Character Ghosts/dad".dance()
	$"Character Ghosts/gf".dance()
	
	$"Character Ghosts/bf"._is_true_player = true
	$"Character Ghosts/bf".scale.x *= -1
	$"Character Ghosts/bf".anim_sprite.position.x += $"Character Ghosts/bf".initial_size.x * absf($"Character Ghosts/bf".anim_sprite.scale.x)
	$"Character Ghosts/bf".dance()
	
func _input(event):
	if event is InputEventKey:
		var key_event:InputEventKey = event as InputEventKey
		
		if event.keycode == KEY_Q:
			camera.zoom *= 0.9
			
		if event.keycode == KEY_E:
			camera.zoom /= 0.9
