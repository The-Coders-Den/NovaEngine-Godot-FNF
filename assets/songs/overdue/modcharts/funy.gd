extends Modchart

var funy:bool = false

func _ready():
	game.player_strums.autoplay = true
	
func on_note_hit(e:NoteHitEvent):
	if e.note.strum_line != game.player_strums:
		return
	
	game.combo += 1
	
	var event := game.pop_up_score(Timings.judgements[0], game.combo, true)
	if event.judgement.do_splash:
		var receptor:Receptor = game.player_strums.receptors.get_child(e.note.data.direction)
		game.do_splash(receptor, e.note)

func on_start_song(e:CancellableEvent):
	funy = true
	
func _process(delta:float):
	if not funy: return
	game.opponent.scale.x -= delta * 0.1
	Conductor.rate += delta * 0.1
