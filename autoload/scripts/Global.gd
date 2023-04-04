extends Node

var SONG:Chart
var note_directions:PackedStringArray = [
	"left", "down", "up", "right"
]
var note_skins:Dictionary = {
	"default": preload("res://scenes/gameplay/noteskins/default.tscn").instantiate(),
	"pixel": preload("res://scenes/gameplay/noteskins/pixel.tscn").instantiate()
}

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)

func add_zeros(str:String, num:int):
	while len(str) < num:
		str = "0"+str
	return str

func bytes_to_human(size:float):
	var labels:PackedStringArray = ["b", "kb", "mb", "gb", "tb"]
	var r_size:float = size
	var label:int = 0
	
	while r_size > 1024 and label < labels.size() - 1:
		label += 1
		r_size /= 1024
	
	return str(snappedf(r_size / 1048576, 0.01)) + labels[label]
