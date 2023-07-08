class_name Stage extends Node2D

@onready var character_positions:Node = $"Character Positions"

## The amount of camera zoom used in-game.
## Acts as a multiplier.
@export var default_cam_zoom:float = 1.05
