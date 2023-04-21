extends OptionButton

func _ready():
	text = str(SettingsAPI.get_setting("fps"))

func _on_item_selected(index:int):
	SettingsAPI.set_setting("fps", int(text))
	SettingsAPI.flush()
	SettingsAPI.update_settings()
