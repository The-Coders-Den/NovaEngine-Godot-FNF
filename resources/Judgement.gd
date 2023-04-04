extends Resource
class_name Judgement

var name:String = "sick"
var score:int = 350
var ms_needed:float = 0.0
var accuracy_gain:float = 0.0
var do_splash:bool = false

static func create(name:String, score:int = 0, ms_needed:float = 0.0, accuracy_gain:float = 0.0, do_splash:bool = false):
	var j = new()
	j.name = name
	j.score = score
	j.ms_needed = ms_needed
	j.accuracy_gain = accuracy_gain
	j.do_splash = do_splash
	return j
