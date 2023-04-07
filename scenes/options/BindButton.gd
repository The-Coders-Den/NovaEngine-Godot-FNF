extends Button
class_name BindButton

enum BindType {
	STANDARD = 0,
	ALT
}

@export var bind:String = "note_left"
@export var bind_type:BindType = BindType.STANDARD

var selecting_bind:bool = false

func _ready():
	text = SettingsAPI.get_setting(bind)[bind_type]

func _on_pressed():
	if selecting_bind: return
	selecting_bind = true
	
	text = "..."
	
func _input(event):
	if event is InputEventKey and selecting_bind:
		selecting_bind = false
		var key_event:InputEventKey = event
		var key_str:String = OS.get_keycode_string(event.keycode)
		print("yo bind is now "+key_str)
		
		text = key_str.to_upper()
		SettingsAPI._settings[bind][bind_type] = key_str.to_upper()
		SettingsAPI.flush()
		SettingsAPI.setup_binds()
