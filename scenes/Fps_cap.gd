extends OptionButton

func _ready():
	text = str(SettingsAPI.get_setting("FPS"))

func _on_item_selected(index):
	SettingsAPI.set_setting("FPS",int(text))
	SettingsAPI.flush()
	Engine.max_fps = int(text)
