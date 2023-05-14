extends Character

var _spectator_chart:Array[SectionNote] = []

func _ready() -> void:
	super._ready()
	
	if _spectator_chart_exists():
		load_animation_notes()

func _process(delta:float) -> void:
	super._process(delta)
	
	while not _spectator_chart.is_empty():
		var spec_note:SectionNote = _spectator_chart[0]
		
		if Conductor.position > spec_note.time:
			var anim_number: int = 3 if spec_note.direction >= 2 else 1
			anim_number += randi_range(0, 1)
			
			play_anim("shoot" + str(anim_number), true)
			_spectator_chart.erase(spec_note)
		else:
			break
	
	if not anim_sprite.is_playing():
		anim_sprite.frame = anim_sprite.sprite_frames.get_frame_count(anim_sprite.animation) - 3
		anim_sprite.play()

func load_animation_notes():
	var chart_temp:Chart = Chart.load_chart(Global.SONG.raw_name, "spectator_notes")
	
	for sec in chart_temp.sections:
		for note in sec.notes:
			_spectator_chart.append(note)
	
	_spectator_chart.sort_custom(func(a:SectionNote, b:SectionNote): 
		return a.time < b.time)

func _spectator_chart_exists():
	return ResourceLoader.exists("res://assets/songs/"+Global.SONG.raw_name+ \
		"/spectator_notes.json")

func dance(force:bool = false) -> void:
	pass
