extends Node

func chart_json(song:String, difficulty:String):
	return "res://assets/funkin/songs/%s/%s.json" % [song.to_lower(), difficulty.to_lower()]
