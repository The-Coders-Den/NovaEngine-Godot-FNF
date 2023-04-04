extends Node2D
class_name Stage

@onready var game:Gameplay = $"../"
@export var default_cam_zoom:float = 1.05

@onready var character_positions:Dictionary = {
	"opponent": $"Character Positions/Opponent",
	"spectator": $"Character Positions/Spectator",
	"player": $"Character Positions/Player"
}
