class_name Timings extends Node

static var judgements:Array[Judgement] = [
	Judgement.new("sick", 45.0,  350, 1.0, 1.0,  true),
	Judgement.new("good", 90.0,  200, 0.7, 0.75, false),
	Judgement.new("bad",  135.0, 100, 0.3, 0.5,  false),
	Judgement.new("shit", 180.0, 50,  1.0, -2.7, false)
]
static var ranks:Array[Rank] = [
	Rank.new("S+", 100.0, 0xFF00CCFF),
	Rank.new("S",  90.0,  0xFF00FD69),
	Rank.new("A",  80.0,  0xFF33FF00),
	Rank.new("B",  70.0,  0xFF9DFF00),
	Rank.new("C",  60.0,  0xFFFFEE00),
	Rank.new("D",  50.0,  0xFFFFAE00),
	Rank.new("E",  40.0,  0xFFFF9900),
	Rank.new("F",  30.0,  0xFFFF6600)
]

static var _default_judgements:Array[Judgement] = []
static var _default_ranks:Array[Rank] = []

static func init():
	for judge in judgements:
		_default_judgements.append(judge.duplicate(true))
		
	for rank in ranks:
		_default_ranks.append(rank.duplicate(true))
		
static func get_judgement(ms_time:float):
	for judge in judgements:
		if judge.timing >= absf(ms_time):
			return judge
		
	return judgements[judgements.size() - 1]
	
static func get_rank(accuracy:float):
	for rank in ranks:
		if rank.accuracy <= accuracy:
			return rank
		
	return ranks[ranks.size() - 1]

class Judgement extends Resource:
	var name:String
	var timing:float
	var score:int
	var accuracy_mult:float
	var health_mult:float
	var do_splash:bool
	
	func _init(name:String, timing:float, score:int, accuracy_mult:float, health_mult:float, do_splash:bool):
		self.name = name
		self.timing = timing
		self.score = score
		self.accuracy_mult = accuracy_mult
		self.health_mult = health_mult
		self.do_splash = do_splash
		
class Rank extends Resource:
	var name:String
	var accuracy:float
	var color:Color
	
	func _init(name:String, accuracy:float, color:Color):
		self.name = name
		self.accuracy = accuracy
		self.color = color
