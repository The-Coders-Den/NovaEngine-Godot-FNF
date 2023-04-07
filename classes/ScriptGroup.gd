extends Node
class_name ScriptGroup

var scripts:Array[FunkinScript] = []

func call_func(func_name:String, args:Array[Variant], default_return:Variant = null):
	var finalized_return:Variant = default_return
	
	var i:int = 0
	for s in scripts:
		# If the modchart is dead, remove it from
		# the list and continue on
		if s == null or !is_instance_valid(s):
			scripts.remove_at(i)
			continue
			
		var return_value:Variant = s.callv(func_name, args)
		if return_value != null and return_value != default_return:
			finalized_return = return_value
			
		i += 1
		
	return finalized_return

func add_script(script:FunkinScript):
	scripts.append(script)
	add_child(script)
	
func remove_script(script:FunkinScript):
	scripts.append(script)
	remove_child(script)
