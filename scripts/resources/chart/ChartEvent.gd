class_name ChartEvent extends Resource

var name:String = "???"
var parameters:Array[Variant] = []

func _init(name:String, parameters:Array[Variant]):
	self.name = name
	self.parameters = parameters

func copy():
	return new(name, parameters.duplicate(true))
