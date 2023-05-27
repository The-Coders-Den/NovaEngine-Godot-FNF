extends Node

const _json_path:String = "user://funkin_settings.json"
var _settings:Dictionary = {
	# gameplay
	"downscroll": false,
	"centered notefield": false,
	"ghost tapping": true,
	"miss sounds": true,
	"show ms on note hit": false,
	"skip intro by default": false,
	
	"note offset": 0.0,
	"scroll speed": 0.0,
	"scroll speed type": "Multiplier",
	
	# appearance
	"fps counter": true,
	"note splashes": true,
	"opaque sustains": false,
	"subtitles": true,
	"story always yellow": false,
	"judgement camera": "World",
	"judgement stacking": true,
	"hide score": false,
	"freeplay icon bumping": true,
	
	# misc
	"auto pause": true,
	"volume beep pitching": false,
	"vsync": false,
	"multi threaded rendering": false,
	"fps": 240,
	
	# controls (gameplay)
	"note_left": ["D", "LEFT", "2_JOY"],
	"note_down": ["F", "DOWN", "0_JOY"],
	"note_up": ["J", "UP", "3_JOY"],
	"note_right": ["K", "RIGHT", "1_JOY"],
	
	# controls (ui)
	"ui_left": ["A", "LEFT", "2_JOY"],
	"ui_down": ["S", "DOWN", "0_JOY"],
	"ui_up": ["W", "UP", "3_JOY"],
	"ui_right": ["D", "RIGHT", "1_JOY"],
	
	"ui_accept": ["ENTER", "SPACE", "0_JOY"],
	"ui_cancel": ["BACKSPACE", "ESCAPE", "4_JOY"],
	"ui_pause": ["ENTER", "UNKNOWN", "6_JOY"],
	"switch_mod": ["TAB", "SHIFT", "9_JOY"],
	
	"volume_up": ["EQUAL", "KP ADD", "UNKNOWN"],
	"volume_down": ["MINUS", "KP SUBTRACT", "UNKNOWN"],
	"volume_mute": ["0", "INSERT", "UNKNOWN"],
	
	# engine
	"current mod": "Friday Night Funkin'",
	"volume": 0.5,
	"muted": false,
}

func setup_binds():
	Input.set_use_accumulated_input(false)
	
	var binds:PackedStringArray = [
		"note_left", "note_down", "note_up", "note_right",
		"ui_pause", "switch_mod",
		"volume_down", "volume_up", "volume_mute"
	] 
	for bind in binds:
		var keys = InputMap.action_get_events(bind)
		
		# normal bind
		var event1 = InputEventKey.new()
		event1.set_keycode(OS.find_keycode_from_string(_settings[bind][0].to_lower()))
		
		# alt bind
		var event2 = InputEventKey.new()
		event2.set_keycode(OS.find_keycode_from_string(_settings[bind][1].to_lower()))
		#print(_settings[bind])
		# Joypad button bind
		var event3 = InputEventJoypadButton.new()
		event3.button_index = int(str(_settings[bind][2]).left(_settings[bind][2].length() - 4))
		
		if keys.size() - 1 != -1: # error handling
			for i in keys:
				InputMap.action_erase_event(bind, i)
		else:
			InputMap.add_action(bind)
		
		InputMap.action_add_event(bind, event1)
		InputMap.action_add_event(bind, event2)
		InputMap.action_add_event(bind, event3)


func _ready():
	var json:Dictionary = {}
	
	if not ResourceLoader.exists(_json_path):
		var f = FileAccess.open(_json_path, FileAccess.WRITE)
		f.store_string("{}")
	else:
		var f = FileAccess.open(_json_path, FileAccess.READ)
		if f.get_as_text() == null or len(f.get_as_text()) < 1:
			json = {}
		else:
			json = JSON.parse_string(f.get_as_text())
		
	for key in _settings:
		if not key in json:
			json[key] = _settings[key]
			print(key+" not present, creating it!")
		else:
			_settings[key] = json[key]
			print(key+" initialized successfully!")
			
	var f = FileAccess.open(_json_path, FileAccess.WRITE)
	f.store_string(JSON.stringify(json))
	
	setup_binds()
	update_settings()
	
	print("Initialized settings!")
	
func update_settings() -> void:
	for key in _settings.keys():
		match key:
			"vsync":
				Global.set_vsync(_settings[key])
			"multi threaded rendering":
				ProjectSettings.set_setting("rendering/driver/threads/thread_model", "Multi-Threaded" if _settings[key] else "Single-Safe")
			"fps":
				Engine.max_fps = _settings[key]

func get_setting(name:String):
	if name in _settings:
		return _settings[name]
		
	return null
	
func set_setting(name:String, value:Variant):
	_settings[name] = value
	
func flush():
	var file := FileAccess.open(_json_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(_settings))
