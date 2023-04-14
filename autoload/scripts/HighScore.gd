extends Node
const _json_path:String = "user://funkin_scores.json"
var scores:Dictionary = {}
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
		
	scores = json
	var f = FileAccess.open(_json_path, FileAccess.WRITE)
	f.store_string(JSON.stringify(json))
	print("Initialized scores!")
	print(scores)
func get_score(name:String,diff:String):
	var CHESSE = name.to_lower()+"-"+diff.to_lower()+"-"+SettingsAPI.get_setting("current mod")
	if not CHESSE in scores:
		return 0
	return scores[CHESSE]
func set_score(name:String,diff:String,score:int):
	scores[name.to_lower()+"-"+diff.to_lower()+"-"+SettingsAPI.get_setting("current mod")] = score
	var f = FileAccess.open(_json_path, FileAccess.WRITE)
	f.store_string(JSON.stringify(scores))
