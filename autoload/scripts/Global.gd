extends Node

var SONG:Chart

const note_directions:Array[String] = [
	"left", "down", "up", "right",
]

var ui_skins:Dictionary = {
	"default": preload("res://scenes/gameplay/ui_skins/default.tscn").instantiate(),
	"pixel": preload("res://scenes/gameplay/ui_skins/pixel.tscn").instantiate(),
}

var scene_arguments:Dictionary = {
	"options_menu": {
		"exit_scene_path": ""
	}
}

var game_size:Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height"),
)

var current_difficulty:String = "hard"

var is_story_mode:bool = false
var queued_songs:PackedStringArray = []

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	
var tree_paused:bool = false

func set_vsync(value:bool):
	if value:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if SettingsAPI.get_setting("vsync") else DisplayServer.VSYNC_DISABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
func _notification(what):
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			if SettingsAPI.get_setting("auto pause"):
				set_vsync(false)
				Engine.max_fps = 10
				
				Audio.process_mode = Node.PROCESS_MODE_INHERIT
				Transition.process_mode = Node.PROCESS_MODE_INHERIT
				tree_paused = get_tree().paused
				get_tree().paused = true
			
		NOTIFICATION_APPLICATION_FOCUS_IN:
			if SettingsAPI.get_setting("auto pause"):
				set_vsync(true)
				Engine.max_fps = 0
				
				Audio.process_mode = Node.PROCESS_MODE_ALWAYS
				Transition.process_mode = Node.PROCESS_MODE_ALWAYS
				get_tree().paused = tree_paused
				
var transitioning:bool = false

func switch_scene(path:String) -> void:
	transitioning = true
	get_tree().paused = true
	
	var anim_player:AnimationPlayer = Transition.anim_player
	anim_player.play("in")
	
	await get_tree().create_timer(anim_player.get_animation("in").length).timeout
	
	get_tree().change_scene_to_file(path)
	
	await get_tree().create_timer(0.05).timeout
	
	anim_player.play("out")
	
	await get_tree().create_timer(anim_player.get_animation("out").length).timeout
	
	transitioning = false
	get_tree().paused = false
	
func reset_scene() -> void:
	transitioning = true
	get_tree().paused = true
	
	var anim_player:AnimationPlayer = Transition.anim_player
	anim_player.play("in")
	
	await get_tree().create_timer(anim_player.get_animation("in").length).timeout
	
	get_tree().reload_current_scene()
	
	await get_tree().create_timer(0.05).timeout
	
	anim_player.play("out")
	
	await get_tree().create_timer(anim_player.get_animation("out").length).timeout
	
	transitioning = false
	get_tree().paused = false

func _input(event:InputEvent) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		var window:Window = get_window()
		if window.mode == Window.MODE_FULLSCREEN:
			window.mode = Window.MODE_WINDOWED
		else:
			window.mode = Window.MODE_FULLSCREEN
			
func list_files_in_dir(path:String):
	var files:PackedStringArray = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()

		while true:
			var file = dir.get_next()
			if file == "": break
			elif not file.begins_with("."):
				files.append(file)

		dir.list_dir_end()
		
	return files

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
