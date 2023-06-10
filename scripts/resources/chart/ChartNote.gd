class_name ChartNote extends Resource

var time:float
var direction:int
var length:float
var strumline:int
var type:String

func _init(time:float, direction:int, length:float, strumline:int, type:String):
	self.time = time
	self.direction = direction
	self.length = length
	self.strumline = strumline
	self.type = type

func copy():
	return new(time, direction, length, strumline, type)
