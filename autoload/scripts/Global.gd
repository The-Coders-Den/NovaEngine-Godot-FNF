extends Node

var SONG:Chart

const note_directions:Array[String] = [
	"left", "down", "up", "right",
]

const audio_formats:PackedStringArray = [".ogg", ".mp3", ".wav"]

var scene_arguments:Dictionary = {
	"options_menu": {
		"exit_scene_path": ""
	}
}

var game_size:Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height"),
)

var death_camera_zoom:Vector2 = Vector2.ONE
var death_camera_pos:Vector2 = Vector2.ZERO
var death_char_pos:Vector2 = Vector2(700, 360)
var death_character:String = "bf-dead"

var health_gain_mult:float = 1.0
var health_loss_mult:float = 1.0

var death_sound:AudioStream = preload("res://assets/sounds/death/fnf_loss_sfx.ogg")
var death_music:AudioStream = preload("res://assets/music/gameOver.ogg")
var retry_sound:AudioStream = preload("res://assets/music/gameOverEnd.ogg")

var current_difficulty:String = "hard"

var is_story_mode:bool = false
var queued_songs:PackedStringArray = []

func _ready() -> void:
	last_scene_path = get_tree().current_scene.scene_file_path
	ModManager.switch_mod(SettingsAPI.get_setting("current mod"))
	RenderingServer.set_default_clear_color(Color.BLACK)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
var tree_paused:bool = false

func set_vsync(value:bool):
	if value:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
func _notification(what):
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			if SettingsAPI.get_setting("auto pause"):
				set_vsync(SettingsAPI.get_setting('vsync'))
				Engine.max_fps = 10
				
				Audio.process_mode = Node.PROCESS_MODE_INHERIT
				Transition.process_mode = Node.PROCESS_MODE_INHERIT
				tree_paused = get_tree().paused
				get_tree().paused = true
			
		NOTIFICATION_APPLICATION_FOCUS_IN:
			if SettingsAPI.get_setting("auto pause"):
				set_vsync(SettingsAPI.get_setting('vsync'))
				Engine.max_fps = SettingsAPI.get_setting("fps")
				
				Audio.process_mode = Node.PROCESS_MODE_ALWAYS
				Transition.process_mode = Node.PROCESS_MODE_ALWAYS
				get_tree().paused = tree_paused
				
var transitioning:bool = false
var last_scene_path:String

func switch_scene(path:String) -> void:
	last_scene_path = path
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
	
func reset_scene(from_mod_menu:bool = false) -> void:
	transitioning = true
	get_tree().paused = true
	
	var anim_player:AnimationPlayer = Transition.anim_player
	anim_player.play("in")
	
	await get_tree().create_timer(anim_player.get_animation("in").length).timeout
	
	if from_mod_menu:
		get_tree().change_scene_to_file("res://scenes/ReloadHelper.tscn")
	else:
		get_tree().change_scene_to_file(last_scene_path)
	
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
	
func float_to_minute(value:float) -> int:
	return int(value / 60)
	
func float_to_seconds(value:float) -> float: 
	return fmod(value, 60)

func format_time(value:float) -> String:
	if value < 0.0: value = 0.0
	return "%02d:%02d" % [float_to_minute(value), float_to_seconds(value)]
