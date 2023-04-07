extends OptionButton
class_name OptionDropdown

@export var option:String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	var item_list:PackedStringArray = []
	for n in item_count:
		item_list.append(get_item_text(n))
		
	select(item_list.find(SettingsAPI.get_setting(option)))

func _on_item_selected(index:int):
	SettingsAPI.set_setting(option, get_item_text(index))
	SettingsAPI.flush()
	
	SettingsAPI.update_settings()
