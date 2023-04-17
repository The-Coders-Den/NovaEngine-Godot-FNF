extends Node
class_name Cutscene
@onready var game:Gameplay = $"../../"
signal on_end
# overide this shit
func _end():
	on_end.emit()
	game.in_cutscene = false
	get_tree().paused = false
	if not game.starting_song:
		game.end_song()
	queue_free()
