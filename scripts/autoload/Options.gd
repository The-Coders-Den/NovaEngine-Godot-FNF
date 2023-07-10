extends Node

#-- important, don't touch --#
var __config:ConfigFile

#-- constants --#
const SAVE_FILE_PATH := "user://funkin_settings.cfg"

#-- engine settings --#
var volume:float = 0.3
var muted:bool = false

#-- funkin settings --#
var downscroll:bool = false
var centered_notefield:bool = false
var ghost_tapping:bool = true
var safe_frames:int = 10
var judgement_timings:Dictionary = JudgementTimings.VANILLA
var note_offset:float = 0.0
var sustain_layer:SustainLayer = SustainLayer.BEHIND
var splash_opacity:int = 60
var judgement_camera:JudgementCamera = JudgementCamera.WORLD
var simply_judgements:bool = false
var anti_aliasing:bool = true
var flashing_lights:bool = true
var reduce_motion:bool = false
var distractions:bool = true
var framerate_cap:int = 120
var vsync:bool = false

#-- enums --#
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
	RenderingServer.set_default_clear_color(Color.BLACK)
	setup()
	apply("all")
	
func apply(setting:String):
	if setting.to_lower() == "all":
		var properties:Array[Dictionary] = get_script().get_script_property_list()
		properties.remove_at(0)
		
		for property in properties:
			if property.name.begins_with("__"):
				continue
			
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
	__config = ConfigFile.new()
	__config.load(SAVE_FILE_PATH)
		
	var properties:Array[Dictionary] = get_script().get_script_property_list()
	properties.remove_at(0)
		
	for property in properties:
		if property.name.begins_with("__"):
			continue
			
		if __config.get_value("Settings", property.name, null) == null:
			print(property.name, " not saved, saving to file")
			__config.set_value("Settings", property.name, get(property.name))
		else:
			print(property.name, " found")
			set(property.name, __config.get_value("Settings", property.name))
	
	__config.save(SAVE_FILE_PATH)
	
func flush():
	if __config == null: return
	
	var properties:Array[Dictionary] = get_script().get_script_property_list()
	properties.remove_at(0)
	
	for property in properties:
		if property.name.starts_with("__"):
			continue
		__config.set_value("Settings", property.name, get(property.name))
		
	__config.save(SAVE_FILE_PATH)
