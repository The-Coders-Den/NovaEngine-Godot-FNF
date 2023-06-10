class_name NoteSpawner extends Node

@onready var game:Gameplay = $"../"

var _note_templates:Dictionary = {}
var _notes_to_spawn:Array[ChartNote] = []
var _connected_strumlines:Array[StrumLine]

#-- use these functions --#
func connect_strumline(strumline:StrumLine):
	_connected_strumlines.append(strumline)
	
func disconnect_strumline(strumline:StrumLine):
	_connected_strumlines.erase(strumline)
	
#-- don't worry about this shit basically lol --#
func _ready():
	_load_note_templates()
	_setup_spawning()

func _load_note_templates():
	for note in Global.CHART.notes:
		if not _note_templates.has(note.type):
			var template_note:Note = load("res://scenes/game/notetypes/Default.tscn").instantiate()
			_note_templates[note.type] = template_note
		else:
			continue
			
func _setup_spawning():
	for note in Global.CHART.notes:
		if note.direction < 0: continue # this is an invalid!! a bade!!!
		_notes_to_spawn.append(note.copy())
		
	_notes_to_spawn.sort_custom(func(a, b): return a.time < b.time)

func _physics_process(delta):
	for note in _notes_to_spawn:
		if note.time > Conductor.position + (2500 / _get_note_speed(note)): break
		
		var new_note:Note = _note_templates[note.type].duplicate()
		new_note.time = note.time
		new_note.direction = note.direction % Global.CHART.key_count
		new_note.length = note.length
		new_note.strumline = _connected_strumlines[note.strumline]
		new_note.type = note.type
		new_note.position = Vector2(-999999, -999999)
		new_note.strumline.notes.add_child(new_note)
		
		new_note.add_anim("normal", Global.dir_to_str(new_note.direction), 24)
		new_note.play_anim("normal")
		
		_notes_to_spawn.erase(note)
		
func _get_note_speed(note:ChartNote):
	var strumline:StrumLine = _connected_strumlines[note.strumline]
	if strumline.scroll_speed != -INF:
		return strumline.scroll_speed / Conductor.rate
		
	var receptor:Receptor = strumline.receptors.get_child(note.direction % Global.CHART.key_count)
	if receptor.scroll_speed != -INF:
		return receptor.scroll_speed / Conductor.rate
		
	if game.scroll_speed != -INF:
		return game.scroll_speed / Conductor.rate
			
	return Global.CHART.scroll_speed / Conductor.rate
