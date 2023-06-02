class_name Gameplay extends Node2D

#-- normal vars --#
var note_data_array:Array[ChartNote] = []
var scroll_speed:float = 2.7

var starting_song:bool = true
var ending_song:bool = false

#-- onready vars #
@onready var template_notes:Dictionary = {
	"default": load("res://scenes/gameplay/notetypes/Default.tscn").instantiate()
}
@onready var hud:Node2D = $HUDContainer/HUD
@onready var strumlines:Node2D = $HUDContainer/HUD/StrumLines
@onready var opponent_strums:StrumLine = $HUDContainer/HUD/StrumLines/OpponentStrums
@onready var player_strums:StrumLine = $HUDContainer/HUD/StrumLines/PlayerStrums
@onready var note_group:NoteGroup = $HUDContainer/HUD/Notes
@onready var tracks:Node = $Tracks

#-- functions (realism) --#
func _ready():
	Statics.SONG_NAME = "m.i.l.f"
	var chart_str:String = FileAccess.open(Paths.chart(Statics.SONG_NAME, "hard"), FileAccess.READ).get_as_text()
	Statics.CHART = Chart.parse_json(JSON.parse_string(chart_str))
	Conductor.setup_song(Statics.CHART)
	Conductor.position = Conductor.crochet * -5
	
	Conductor.beat_hit.connect(beat_hit)
	Conductor.step_hit.connect(beat_hit)
	Conductor.measure_hit.connect(measure_hit)
	
	load_tracks()
	load_notes()
	
func load_tracks():
	var folder:String = Paths.song_folder(Statics.SONG_NAME)+"/audio"
	var dir := DirAccess.open(folder)
	for item in dir.get_files():
		item = item as String
		if not item.ends_with(".import"): continue
		
		var fixed_item:String = Paths.fix(item)
		var track := AudioStreamPlayer.new()
		track.stream = load(folder+"/"+fixed_item)
		tracks.add_child(track)
	
func load_notes():
	for n in Statics.CHART.notes:
		if n.direction < 0: continue
		if not n.type in template_notes:
			var path:String = "res://scenes/gameplay/notetypes/%s.tscn" % n.type
			if ResourceLoader.exists(path):
				template_notes[n.type] = load(path).instantiate()
			else:
				template_notes[n.type] = null
				printerr("Note type called \"%s\" doesn't exist!" % n.type)
		
		note_data_array.append(n.copy())
		
	note_data_array.sort_custom(func(a, b): return a.time < b.time)

func _physics_process(delta):
	for note in note_data_array:
		if note.time >= Conductor.position + (2500 / scroll_speed): break
		spawn_note(note)
		note_data_array.erase(note)
		
func _process(delta):
	Conductor.position += delta * 1000.0
	if Conductor.position >= 0.0 and starting_song:
		start_song()
		
func start_song():
	starting_song = false
	Conductor.position = 0.0
	
	for track in tracks.get_children():
		track = track as AudioStreamPlayer
		track.play()
		
func resync_tracks():
	for track in tracks.get_children():
		track.seek(Conductor.position / 1000.0)
		
func spawn_note(note_data:ChartNote):
	var type:String = "default"
	if note_data.type in template_notes and template_notes[note_data.type] != null:
		type = note_data.type
		
	var new_note:Note = template_notes[type].duplicate()
	new_note.position = Vector2(-9999, -9999) # hacky workaround to prevent you from seeing the notes spawn
	new_note.time = note_data.time
	new_note.direction = note_data.direction % 4
	new_note.length = note_data.length
	new_note.type = note_data.type
	new_note.alt_anim = note_data.type == "Alt Animation"
	new_note.strumline = strumlines.get_child(note_data.strumline)
	note_group.add_child(new_note)
	new_note.sprite.play(Tools.dir_to_str(new_note.direction))

func dir_from_event(event:InputEvent):
	var dir:int = -1
	for _dir in Tools.NoteDirection.values():
		var dir_str:String = Tools.dir_to_str(_dir)
		var formatted_dir:String = "note_%s" % dir_str
		if event.is_action_pressed(formatted_dir) or event.is_action_released(formatted_dir):
			dir = _dir
			break
			
	return dir

func _unhandled_key_input(event:InputEvent):
	var dir:int = dir_from_event(event)
	if dir == -1: return
	
	var receptor:Receptor = player_strums.get_child(dir)
	if event.is_pressed() and not receptor.pressed:
		receptor.pressed = true
		var possible_notes:Array[Node] = note_group.get_children().filter(func(note:Note):
			var can_be_hit:bool = (note.time > Conductor.position - Conductor.safe_zone_offset and note.time < Conductor.position + (Conductor.safe_zone_offset * 1.5))
			var too_late:bool = (note.time < Conductor.position - Conductor.safe_zone_offset and not note.was_already_hit)
			return note.strumline == player_strums and note.direction == dir and can_be_hit and not too_late
		)
		if possible_notes.size() > 0:
			possible_notes.sort_custom(sort_hit_notes)
			# delete stacked notes
			for i in possible_notes.size():
				if i == 0: continue
				var note:Note = possible_notes[i]
				if absf(note.time - possible_notes[0].time) <= 5:
					note.queue_free()
				else:
					break
			# delete the real note
			good_note_hit(possible_notes[0])
		
		player_strums.play_anim(dir, Tools.ReceptorAnim.CONFIRM if possible_notes.size() > 0 else Tools.ReceptorAnim.PRESSED)
	else:
		receptor.pressed = false
		player_strums.play_anim(dir, Tools.ReceptorAnim.STATIC)

func good_note_hit(note:Note):
	note.queue_free()

func sort_hit_notes(a:Note, b:Note):
	if not a.should_hit and b.should_hit: return 0
	elif a.should_hit and not b.should_hit: return 1
	return a.time < b.time
	
func beat_hit(beat:int):
	for track in tracks.get_children():
		if absf((track.get_playback_position() * 1000.0) - Conductor.position) >= 20:
			resync_tracks()
	
func step_hit(step:int):
	pass

func measure_hit(measure:int):
	pass
