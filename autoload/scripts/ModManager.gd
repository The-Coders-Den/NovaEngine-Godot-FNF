extends Node

const MOD_FOLDER:String = "user://mods/"
const FALLBACK_MOD:String = "Friday Night Funkin'"

var path_lookup:Dictionary = {
	FALLBACK_MOD: "Nova Engine.pck"
}

func _ready() -> void:
	if not DirAccess.dir_exists_absolute(MOD_FOLDER):
		DirAccess.make_dir_absolute(MOD_FOLDER)
		
	var mod_list:PackedStringArray = list_all_mods()
	for i in mod_list.size():
		var mod_name:String = mod_list[i].get_basename().replace(MOD_FOLDER, "")
		path_lookup[mod_name] = mod_list[i]

# lists all paths to every mod pck found
func list_all_mods() -> PackedStringArray:
	var mod_list:PackedStringArray = []
	for i in Global.list_files_in_dir(MOD_FOLDER):
		var item:String = i
		if not item.ends_with(".pck"):
			continue
			
		mod_list.append(MOD_FOLDER + item)
		
	return mod_list

func switch_mod(mod_name:String) -> bool:
	if OS.is_debug_build():
		return true
	
	ProjectSettings.load_resource_pack("Nova Engine.pck", true)
	
	# already loads it 2 lines above this
	if mod_name == FALLBACK_MOD:
		return true
	
	# you're wrong, sulfuric modding!
	if not mod_name in path_lookup:
		push_error("Non-existent mod: "+mod_name+" tried to load.")
		return false
	
	# godot is great
	# the entire mod loading is one function
	var success:bool = ProjectSettings.load_resource_pack(path_lookup[mod_name], true)
	if success:
		print("Loaded mod: "+mod_name)
		return true
		
	print("Failed to load mod: "+mod_name)
	return false
