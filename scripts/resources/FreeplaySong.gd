
class_name FreeplaySong extends Resource
@export var song_name:String = "test"
@export var display_name:String = ""
@export var color:Color = Color.WHITE
@export var icon:Texture2D = preload("res://assets/images/game/icons/icon-face.png")
@export var icon_frames:int = 2
@export var bpm:float = 150.0
@export var difficulties:PackedStringArray = ["easy","normal","hard"]