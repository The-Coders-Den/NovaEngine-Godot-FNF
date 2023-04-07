extends CheckBox
class_name OptionCheckbox

@export var option:String = ""

func _ready():
	button_pressed = SettingsAPI.get_setting(option)
	
func _on_pressed():
	SettingsAPI.set_setting(option, not SettingsAPI.get_setting(option))
	SettingsAPI.flush()
	
	SettingsAPI.update_settings()
