extends Node2D
class_name StrumLine

@export var handle_input:bool = true
@export var controls:Array[String] = []

func _input(event):
	if event is InputEventKey and handle_input:
		key_shit()
		
func key_shit():
	for i in get_child_count():
		if Input.is_action_just_released(controls[i]):
			var receptor:Receptor = get_child(i)
			receptor.play_anim("static")
