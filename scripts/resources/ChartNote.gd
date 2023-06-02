class_name ChartNote extends Resource

var time:float = 0.0
var direction:int = 0
var length:float = 0.0
var type:String = "default"
var strumline:int = 0

func copy():
	var copied:ChartNote = new()
	copied.time = time
	copied.direction = direction
	copied.length = length
	copied.type = type
	copied.strumline = strumline
	return copied
