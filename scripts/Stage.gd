extends Node2D
class_name Stage

@onready var game:Gameplay = $"../"

@export var default_cam_zoom:float = 1.05

@export_group("Camera Offsets")
@export var player_cam_offset:Vector2 = Vector2(0.0, 0.0)
@export var opponent_cam_offset:Vector2 = Vector2(0.0, 0.0)

@onready var character_positions:Dictionary = {
	"opponent": $"Character Positions/Opponent",
	"spectator": $"Character Positions/Spectator",
	"player": $"Character Positions/Player"
}

func _ready_post():
	pass
	
func _process_post(delta:float):
	pass
	
func on_start_countdown():
	pass

func on_countdown_tick(tick:int, tween:Tween):
	pass

func on_start_song():
	pass
	
func on_end_song():
	pass

func on_beat_hit(beat:int):
	pass

func on_beat_hit_post(beat:int):
	pass
	
func on_event(name:String, parameters:Array):
	pass
