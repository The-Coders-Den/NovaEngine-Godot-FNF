extends Modchart

var shaking:bool = false
var shake_timer:float = 0.0

const shake_intensity:float = 3.0
const shake_duration:float = 0.01

func _ready():
	game.opponent_strums.receptors.modulate.a = 0.6

func on_note_hit(e:NoteHitEvent):
	if e.note.strum_line != game.opponent_strums:
		return
	
	shaking = true
	shake_timer = 0.0
	
	e.note.hit_allowed = true
	e.cancel()
	
func _physics_process(delta:float):
	if shaking:
		game.opponent_strums.receptors.position = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		game.opponent_strums.notes.position = game.opponent_strums.receptors.position
		shake_timer += delta
		if shake_timer >= shake_duration:
			shaking = false
			shake_timer = 0.0
	else:
		game.opponent_strums.receptors.position = Vector2.ZERO
		game.opponent_strums.notes.position = game.opponent_strums.receptors.position
