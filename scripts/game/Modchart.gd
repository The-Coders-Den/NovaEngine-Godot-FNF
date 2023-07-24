## Please refer to the Signals class
## to see what functions are available.

## Conductor functions are also variable such as:
## _beat_hit, _step_hit, and also _section_hit
class_name Modchart extends Node

var game:Gameplay
var is_event:bool = false

func call_method(method:String, args:Array[Variant]):
	# Method doesn't exist, don't call it
	if not has_method(method): return
	
	# Otherwise do call it!
	callv(method, args)
