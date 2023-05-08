extends HSlider
class_name OptionSlider

@export var option:String = ""

func _ready():
	value = SettingsAPI.get_setting(option)

func _on_value_changed(value:float):
	SettingsAPI.set_setting(option, value)

func _on_drag_ended(value_changed:bool):
	if not value_changed: return
	SettingsAPI.flush()

	SettingsAPI.update_settings()
