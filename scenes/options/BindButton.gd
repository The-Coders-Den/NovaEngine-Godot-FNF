extends Button
class_name BindButton

var joy_array = [ #this is fucking stupid, i blame srt for this :3
	JOY_BUTTON_A,
	JOY_BUTTON_B,
	JOY_BUTTON_X,
	JOY_BUTTON_Y,
	JOY_BUTTON_BACK,
	JOY_BUTTON_GUIDE,
	JOY_BUTTON_START,
	JOY_BUTTON_LEFT_STICK,
	JOY_BUTTON_RIGHT_STICK,
	JOY_BUTTON_LEFT_SHOULDER,
	JOY_BUTTON_RIGHT_SHOULDER,
	JOY_BUTTON_DPAD_UP,
	JOY_BUTTON_DPAD_DOWN,
	JOY_BUTTON_DPAD_LEFT,
	JOY_BUTTON_DPAD_RIGHT,
	JOY_BUTTON_MISC1,
	JOY_BUTTON_PADDLE1,
	JOY_BUTTON_PADDLE2,
	JOY_BUTTON_PADDLE3,
	JOY_BUTTON_PADDLE4,
	JOY_BUTTON_TOUCHPAD,
	JOY_BUTTON_SDL_MAX
]

enum BindType {
	STANDARD = 0,
	ALT,
	JOY
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
	if event is InputEventJoypadButton  and selecting_bind:
		var joypad_event = event as InputEventJoypadButton
		var joypad_index = joypad_event.device
		var button_index = joypad_event.button_index
		
		print("Joypad", joypad_index, "button", button_index)
		print(joy_array[button_index])
		text = str(button_index) + "_JOY"
		SettingsAPI._settings[bind][bind_type] = str(str(button_index) + "_JOY").to_upper()
		SettingsAPI.flush()
		SettingsAPI.setup_binds()
		
		get_tree().create_timer(0.5).timeout.connect(func(): selecting_bind = false)
#
#		text = key_str.to_upper()
#		SettingsAPI._settings[bind][bind_type] = key_str.to_upper()
#		SettingsAPI.flush()
#		SettingsAPI.setup_binds()
#
#		get_tree().create_timer(0.5).timeout.connect(func(): selecting_bind = false)
		
	if event is InputEventKey and selecting_bind:
		var key_event:InputEventKey = event
		var key_str:String = OS.get_keycode_string(event.keycode)
		print("yo bind is now "+key_str+"\nnow we wait a sec until you can set another bind")
		print(key_str)
		text = key_str.to_upper()
		SettingsAPI._settings[bind][bind_type] = key_str.to_upper()
		SettingsAPI.flush()
		SettingsAPI.setup_binds()
		
		get_tree().create_timer(0.5).timeout.connect(func(): selecting_bind = false)
