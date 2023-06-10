extends Node

const IMAGE_EXTS:PackedStringArray = [".png", ".jpg", ".jpeg", ".bmp"]
const AUDIO_EXTS:PackedStringArray = [".ogg", ".mp3", ".wav"]

func chart_json(song:String, difficulty:String):
	return "res://assets/funkin/songs/%s/%s.json" % [song.to_lower(), difficulty.to_lower()]
