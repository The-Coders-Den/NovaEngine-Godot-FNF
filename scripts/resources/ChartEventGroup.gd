class_name ChartEventGroup extends Resource

var time:float = 0.0
var events:Array[ChartEvent] = []

func _init(time:float, events:Array[ChartEvent]):
	self.time = time
	self.events = events

func copy():
	return new(time, events.duplicate(true))
