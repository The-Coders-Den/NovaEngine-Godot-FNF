class_name Chart extends Resource

enum CharacterPosition {
	OPPONENT,
	PLAYER,
	SPECTATOR
}

var song_name:String
@export var bpm:float
@export var display_name:String

@export var notes:Array[ChartNote] = []
@export var events:Array[ChartEventGroup] = []
@export var characters:Array[ChartCharacter] = []
@export var stage:String = "stage"

@export var note_style:String = "default"
@export var ui_style:String = "default"

@export var strum_lines:int = 2
@export var scroll_speed:float = 1.0

@export var beats_per_measure:int = 4
@export var steps_per_beat:int = 4

static func load_chart(song:String, difficulty:String):
	var base_path:String = "res://assets/songs/%s/%s" % [song.to_lower(), difficulty.to_lower()]
	
	# Checks if the chart is a res file
	var is_res:bool = false
	for shitterass in [".res", ".tres"]:
		if ResourceLoader.exists(base_path+shitterass):
			is_res = true
			base_path += shitterass
			break
		
	# If the chart is just a resource,
	# simply load it!
	if is_res:
		return load(base_path)
		
	# Otherwise, parse it (parses vanilla FNF)
	base_path += ".json"
	if not FileAccess.file_exists(base_path):
		printerr("FILE NOT FOUND CANT PARSE CHART") 
		return null
	var json:Dictionary = JSON.parse_string(FileAccess.open(base_path, FileAccess.READ).get_as_text())
	if "song" in json: json = json.song

	var final:Chart = new()
	final.song_name = song
	final.bpm = float(json.bpm)
	_load_psych_events(final, json)
	
	# Parse characters
	var gfVersion:String = "gf"
	
	if "player3" in json and json.player3 != null: gfVersion = json.player3
	if "gfVersion" in json and json.gfVersion != null: gfVersion = json.gfVersion
	if "gf" in json and json.gf != null: gfVersion = json.gf
	
	final.characters = [
		ChartCharacter.new(gfVersion,    2, CharacterPosition.SPECTATOR),
		ChartCharacter.new(json.player2, 0, CharacterPosition.OPPONENT),
		ChartCharacter.new(json.player1, 1, CharacterPosition.PLAYER)
	]
	
	# Parse timescale
	if "beatsPerMeasure" in json: final.beats_per_measure = float(json.beatsPerMeasure)
	if "beats_per_measure" in json: final.beats_per_measure = float(json.beats_per_measure)

	if "stepsPerBeat" in json: final.steps_per_beat = float(json.stepsPerBeat)
	if "steps_per_beat" in json: final.steps_per_beat = float(json.steps_per_beat)
	
	# Parse notes and events
	var cur_bpm:float = final.bpm
	var cur_time:float = 0.0
	var cur_crochet:float = (60.0 / final.bpm) * 1000.0
	var beats_per_measure:float = final.beats_per_measure
	
	var last_camera_switch:bool = not json.notes[0].mustHitSection if json.notes.size() > 0 else false
	
	if "notes" in json:
		for i in json.notes.size():
			var section:Dictionary = json.notes[i]
			if section == null: continue # YCE chart compat
			
			#parse events
			if "changeBPM" in section and section.changeBPM and float(section.bpm) > 0.0 and float(section.bpm) != cur_bpm:
				cur_bpm = float(section.bpm)
				cur_crochet = (60.0 / section.bpm) * 1000.0
				
				var event_group := ChartEventGroup.new(cur_time, [ChartEvent.new("BPM Change", [str(cur_bpm)])])
				final.events.append(event_group)
			
			# parse camera pans
			if last_camera_switch != section.mustHitSection:
				last_camera_switch = section.mustHitSection
				
				var event_group := ChartEventGroup.new(-INF if cur_time <= 0.05 else cur_time, [ChartEvent.new("Camera Pan", [str(last_camera_switch)])])
				final.events.append(event_group)
			
			# parse notes
			if not "sectionNotes" in section:
				printerr("One of your sections somehow has no notes in it!")
				continue
				
			for section_note in section.sectionNotes:
				section_note = section_note as Array
				
				if int(section_note[1]) < 0: # bad note!
					continue
				
				var gotta_hit:bool = !section.mustHitSection if int(section_note[1]) >= 4 else section.mustHitSection
				
				var note := ChartNote.new()
				note.hit_time = section_note[0]
				note.direction = int(section_note[1]) % 4
				note.length = section_note[2]
				
				# fuck u yo sustain too long bitch!
				if note.length <= 100:
					note.length = 0.0
				
				if section_note.size() > 3:
					var da_note_type:String = section_note[3] if section_note[3] != null and section_note[3] is String else "Default"
					if (section_note[3] is bool and section_note[3] == true) or ("altAnim" in section and section.altAnim):
						da_note_type = "Alt Animation"
						
					note.type = da_note_type # how the fuck i forget this shit bro
					
				note.strum_index = 1 if gotta_hit else 0
				
				final.notes.append(note)
			
			cur_time += cur_crochet * beats_per_measure
	else:
		printerr("Your chart somehow has no sections in it!")
	
	# Parse misc properties
	if "displayName" in json: final.display_name = json.displayName
	if "display_name" in json: final.display_name = json.display_name
	if "display" in json: final.display_name = json.display
	if "name" in json: final.display_name = json.name
	if "song" in json: final.display_name = json.song
	
	if "scrollSpeed" in json: final.scroll_speed = json.scrollSpeed
	if "scroll_speed" in json: final.scroll_speed = json.scroll_speed
	if "speed" in json: final.scroll_speed = json.speed
	
	if "noteStyle" in json: final.note_style = json.noteStyle
	if "note_style" in json: final.note_style = json.note_style
	
	if "uiStyle" in json: final.ui_style = json.uiStyle
	if "ui_style" in json: final.ui_style = json.ui_style
	
	if "stage" in json: final.stage = json.stage
		
	return final
	
static func _load_psych_event_array(event_array:Array[Variant]) -> Array[ChartEventGroup]:
	var return_events:Array[ChartEventGroup] = []
	
	# newer multi-event style
	if event_array[1] is Array:
		for inner_event in event_array[1]:
			var song_event:ChartEventGroup = ChartEventGroup.new(event_array[0], [])
			song_event.events.append(ChartEvent.new(inner_event[0], [inner_event[1], inner_event[2]]))
			return_events.append(song_event)
	# older one-event style
	else:
		var song_event:ChartEventGroup = ChartEventGroup.new(event_array[0], [])
		song_event.events.append(ChartEvent.new(event_array[2], [event_array[3], event_array[4]]))
		return_events.append(song_event)
	
	return return_events
	
static func _load_psych_events(CHART:Chart, raw:Dictionary):
	var event_path:String = "res://assets/songs/%s/events.json" % CHART.song_name.to_lower()
	var event_data:Dictionary = {}
	
	if ResourceLoader.exists(event_path):
		event_data = JSON.parse_string(FileAccess.open(event_path, FileAccess.READ).get_as_text())
		if event_data.has('song'):
			event_data = event_data.song
	else:
		event_data = raw
	
	if not event_data.has('events'):
		event_data['events'] = []
	if not event_data.has('notes'):
		event_data['notes'] = []
		
	for event in event_data.events:
		for song_event in _load_psych_event_array(event):
			CHART.events.append(song_event)
			
	for section in event_data.notes:
		for note in section.sectionNotes:
			if note[1] is Array or note[1] < 0:
				for song_event in _load_psych_event_array(note):
					CHART.events.append(song_event)
	
class ChartCharacter extends Resource:
	var name:String
	var strum_index:int
	var position:Chart.CharacterPosition
	
	func _init(name:String = "bf", strum_index:int = 0, position:Chart.CharacterPosition = 0):
		self.name = name
		self.strum_index = strum_index
		self.position = position

class ChartNote extends Resource:
	@export var hit_time:float = 0.0
	@export var direction:int = 0
	@export var length:float = 0.0
	@export var type:String = "default"
	@export var strum_index:int = 0
	
class ChartEvent extends Resource:
	var name:String = "???"
	var parameters:Array[Variant] = []

	func _init(name:String, parameters:Array[Variant]):
		self.name = name
		self.parameters = parameters
		
class ChartEventGroup extends Resource:
	var time:float = 0.0
	var events:Array[ChartEvent] = []

	func _init(time:float, events:Array[ChartEvent]):
		self.time = time
		self.events = events
