extends Node

enum NoteDirection {
	LEFT,
	DOWN,
	UP,
	RIGHT
}

enum ReceptorAnim {
	STATIC,
	PRESS,
	PRESSED,
	HIT,
	CONFIRM,
}

enum StrumLineType {
	OPPONENT,
	PLAYER,
	SPECTATOR
}

func dir_to_str(dir:NoteDirection):
	match dir:
		NoteDirection.LEFT:  return "left"
		NoteDirection.DOWN:  return "down"
		NoteDirection.UP:    return "up"
		NoteDirection.RIGHT: return "right"
		
	return "?"

func _ready():
	pass
