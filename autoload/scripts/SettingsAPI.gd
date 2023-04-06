extends Node

var _json_path:String = "user://funkin_settings.json"
var _settings:Dictionary = {
	# gameplay
	"downscroll": false,
	"centered notefield": false,
	
	# controls (gameplay)
	"note_left": ["D", "LEFT"],
	"note_down": ["F", "DOWN"],
	"note_up": ["J", "UP"],
	"note_right": ["K", "RIGHT"],
	
	# controls (ui)
	"ui_accept": ["ENTER", "SPACE"],
	"ui_cancel": ["BACKSPACE", "ESCAPE"],
	"ui_pause": ["ENTER", "NONE"]
}

func setup_binds():
	Input.set_use_accumulated_input(false)
	
	var binds:PackedStringArray = ["note_left", "note_down", "note_up", "note_right"] 
	for bind in binds:
		var keys = InputMap.action_get_events(bind)
		
		# normal bind
		var event1 = InputEventKey.new()
		event1.set_keycode(OS.find_keycode_from_string(_settings[bind][0].to_lower()))
		
		# alt bind
		var event2 = InputEventKey.new()
		event2.set_keycode(OS.find_keycode_from_string(_settings[bind][1].to_lower()))
		
		if keys.size() - 1 != -1: # error handling shit
			for i in keys:
				InputMap.action_erase_event(bind, i)
		else:
			InputMap.add_action(bind)
			
		InputMap.action_add_event(bind, event1)
		InputMap.action_add_event(bind, event2)

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
		
	print("Initialized settings!")

func get_setting(name:String):
	if name in _settings:
		return _settings[name]
		
	return null