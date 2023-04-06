extends Node

var SONG:Chart
var note_directions:PackedStringArray = [
	"left", "down", "up", "right"
]
var note_skins:Dictionary = {
	"default": preload("res://scenes/gameplay/noteskins/default.tscn").instantiate(),
	"pixel": preload("res://scenes/gameplay/noteskins/pixel.tscn").instantiate()
}

var game_size:Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height"),
)

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	
func _input(event):
	if Input.is_action_just_pressed("fullscreen"):
		var window:Window = get_window()
		if window.mode == Window.MODE_FULLSCREEN:
			window.mode = Window.MODE_WINDOWED
		else:
			window.mode = Window.MODE_FULLSCREEN

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
	
	return str(snappedf(r_size, 0.01)) + labels[label]
	
func format_time(seconds: float):
	var minutes_int: int = int(seconds / 60.0)
	var seconds_int: int = int(seconds) % 60
	
	return "%s:%s" % [minutes_int,
		'0' + str(seconds_int) if seconds_int < 10 else seconds_int]
