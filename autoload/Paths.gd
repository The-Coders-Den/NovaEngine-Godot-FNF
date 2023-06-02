extends Node

func chart(song:String, difficulty:String):
	return "res://assets/songs/%s/%s.json" % [song.to_lower(), difficulty.to_lower()]

func song_folder(song:String):
	return "res://assets/songs/%s" % song.to_lower()
	
func fix(path:String):
	return path.replace(".import", "")
