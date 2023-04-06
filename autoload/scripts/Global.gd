extends Node

var SONG:Chart

const note_directions:Array[String] = [
	"left", "down", "up", "right",
]

var ui_skins:Dictionary = {
	"default": preload("res://scenes/gameplay/ui_skins/default.tscn").instantiate(),
	"pixel": preload("res://scenes/gameplay/ui_skins/pixel.tscn").instantiate(),
}

var game_size:Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height"),
)

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)

func switch_scene(path:String) -> void:
	get_tree().paused = true
	
	var anim_player:AnimationPlayer = Transition.anim_player
	anim_player.play("in")
	
	await get_tree().create_timer(anim_player.get_animation("in").length).timeout
	
	get_tree().change_scene_to_file(path)
	anim_player.play("out")
	
	await get_tree().create_timer(anim_player.get_animation("out").length).timeout
	
	get_tree().paused = false

func _input(event:InputEvent) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		var window:Window = get_window()
		if window.mode == Window.MODE_FULLSCREEN:
			window.mode = Window.MODE_WINDOWED
		else:
			window.mode = Window.MODE_FULLSCREEN

func add_zeros(str:String, num:int) -> String:
	return str.pad_zeros(num)

func bytes_to_human(size:float) -> String:
	var labels:PackedStringArray = ["b", "kb", "mb", "gb", "tb"]
	var r_size:float = size
	var label:int = 0
	
	while r_size > 1024 and label < labels.size() - 1:
		label += 1
		r_size /= 1024
	
	return str(r_size).pad_decimals(2) + labels[label]
	
func format_time(seconds: float) -> String:
	var minutes_int: int = int(seconds / 60.0)
	var seconds_int: int = int(seconds) % 60
	
	return "%s:%s" % [minutes_int, add_zeros(str(seconds_int), 1)]
