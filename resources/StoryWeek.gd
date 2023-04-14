extends Resource
class_name StoryWeek

@export_group("Display Data")
@export var name:String = "Week Name"
@export var week_texture:CompressedTexture2D
@export var bg_color:Color = Color(0.976470588, 0.811764705882, 0.317647058824)
@export var player:String = "bf"
@export var opponent:String = "dad"
@export var specator:String = "gf"

@export_group("Internal Data")
@export var name_in_save:String = "weekIDK"
@export var songs:Array[StorySong] = []
@export var difficulties:PackedStringArray = ["easy", "normal", "hard"]
