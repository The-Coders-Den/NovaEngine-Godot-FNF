extends Node

#-- constants --#
const SAVE_FILE_PATH := "user://funkin_settings.json"

#-- engine settings --#
var volume:float = 0.3
var muted:bool = false

#-- funkin settings --#
var scroll_type:ScrollType = ScrollType.UP
var centered_notefield:bool = false
var ghost_tapping:bool = true
var safe_frames:int = 10
var judgement_timings:Dictionary = JudgementTimings.VANILLA
var note_offset:float = 0.0
var sustain_layer:SustainLayer = SustainLayer.ABOVE
var splash_opacity:float = 60
var judgement_camera:JudgementCamera = JudgementCamera.WORLD
var anti_aliasing:bool = true
var flashing_lights:bool = true
var reduce_motion:bool = false
var distractions:bool = true
var framerate_cap:int = 120
var vsync:bool = false

#-- enums --#
enum ScrollType {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

enum SustainLayer {
	BEHIND,
	ABOVE
}

enum IconBump {
	DEFAULT,
	CLASSIC,
	PSYCH,
	OS,
	FUNKY
}

enum JudgementCamera {
	WORLD,
	HUD
}

#-- functions --#
func _ready():
	setup()
	apply("all")
	
func apply(setting:String):
	if setting.to_lower() == "all":
		var properties:Array[Dictionary] = get_script().get_script_property_list()
		properties.remove_at(0)
		
		for property in properties:
			apply(property.name)
		return
		
	#-----------------------------#
	match setting:
		"framerate_cap":
			Engine.max_fps = framerate_cap
			
		"anti_aliasing":
			var filter:int = CanvasItem.TEXTURE_FILTER_LINEAR if anti_aliasing else CanvasItem.TEXTURE_FILTER_NEAREST
			ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", filter)
	
		"vsync":
			var vsync:int = DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED
			DisplayServer.window_set_vsync_mode(vsync)
	
func setup():
	var properties:Array[Dictionary] = get_script().get_script_property_list()
	properties.remove_at(0)
	
	var json:Dictionary = {}
	
	if not ResourceLoader.exists(SAVE_FILE_PATH):
		var f = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
		f.store_string("{}")
	else:
		var f = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if f.get_as_text() == null or len(f.get_as_text()) < 1:
			json = {}
		else:
			json = JSON.parse_string(f.get_as_text())
			
	for key in properties:
		if not key.name in json:
			json[key.name] = get(key.name)
		else:
			set(key.name, json[key.name])
			
	var f := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(json))

func flush():
	var _settings:Dictionary = {}
	
	var properties:Array[Dictionary] = get_script().get_script_property_list()
	properties.remove_at(0)
	
	for property in properties:
		_settings[property.name] = get(property.name)
	
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(_settings))
