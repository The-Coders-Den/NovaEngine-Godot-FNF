extends Sprite2D
class_name HealthIcon

@export var react_to_health:bool = false

var health:float = 50.0

func get_icon_index(health:float, icons:int):
	match icons:
		1:
			return 0
		2:
			if health < 20: return 0
			return 1
		3:
			if health < 20: return 0
			if health > 80: return 2
			return 1
		_:
			for i in icons:
				if health > (100.0 / icons) * (i+1): continue
				
				# finds the first icon we are less or equal to, then choose it
				return i
		
	return 0

func _process(delta):
	if hframes == 1 or not react_to_health: return
	
	var _frame:int = get_icon_index(health, hframes)
	if _frame == 0: _frame = 1
	elif _frame == 1: _frame = 0
	frame = _frame
