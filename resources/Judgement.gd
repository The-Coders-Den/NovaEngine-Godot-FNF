extends Resource
class_name Judgement

var name:String = "sick"
var score:int = 350
var ms_needed:float = 0.0
var accuracy_gain:float = 0.0
var health_gain_mult:float = 0.0
var do_splash:bool = false
var color:Color = Color.CYAN

static func create(name:String, score:int = 0, ms_needed:float = 0.0, accuracy_gain:float = 0.0, health_gain_mult:float = 1.0, do_splash:bool = false, color:Color = Color.CYAN):
	var j = new()
	j.name = name
	j.score = score
	j.ms_needed = ms_needed
	j.accuracy_gain = accuracy_gain
	j.health_gain_mult = health_gain_mult
	j.do_splash = do_splash
	j.color = color
	return j
