extends Resource
class_name AccuracyRank

var name:String = "S+"
var accuracy_needed:float = 100.0

static func create(name:String, accuracy_needed:float = 0.0):
	var j = new()
	j.name = name
	j.accuracy_needed = accuracy_needed
	return j
