class_name Chart extends Resource

## The name that is displayed in Gameplay
## and the Pause Menu.
var name:String = "Test"

## The BPM (Beats Per Minute) of the chart.
var bpm:float = 0.0

## The notes in the chart.
var notes:Array[ChartNote] = []

## The events in the chart.
var events:Array[ChartEventGroup] = []

## A list of every note type in the chart.
## Only used when notes specify an int notetype.
var notetypes:PackedStringArray = []

var characters:Dictionary = {
	"opponent": [],
	"spectator": [],
	"player": [],
}

var beats_per_measure:float = 4.0
var steps_per_beat:float = 4.0

## Parses base game/psych chart data into
## a easy to use a resource
static func parse_json(json:Dictionary):
	# gonna add custom chart format
	# in the future
	# but for now base game only
	return parse_vanila_json(json)
	
static func parse_nova_json(json:Dictionary):
	var parsed:Chart = new()
	parsed.bpm = float(json.bpm)
	parsed.name = json.name
	
	return parsed
	
static func parse_vanila_json(json:Dictionary):
	if "song" in json and json.song is Dictionary:
		json = json.song
	
	var parsed:Chart = new()
	parsed.bpm = float(json.bpm)
	parsed.name = json.song
	parsed.characters.opponent = [json.player2]
	parsed.characters.player = [json.player1]
	parsed.characters.spectator = ["gf"]
	
	# gf shit
	if "player3" in json:
		parsed.characters.spectator = [json.player3]
		
	if "gfVersion" in json:
		parsed.characters.spectator = [json.gfVersion]
		
	if "gf" in json:
		parsed.characters.spectator = [json.gf]
	
	# timescale shit
	if "beatsPerMeasure" in json:
		parsed.beats_per_measure = float(json.beatsPerMeasure)
		
	if "stepsPerBeat" in json:
		parsed.steps_per_beat = float(json.stepsPerBeat)
		
	# stupid capitilization shit
	if "notetypes" in json:
		parsed.notetypes = json.notetypes
		
	if "noteTypes" in json:
		parsed.notetypes = json.noteTypes
	
	var cur_bpm:float = parsed.bpm
	var cur_time:float = 0.0
	var cur_crochet:float = (60.0 / parsed.bpm) * 1000.0
	var beats_per_measure:float = parsed.beats_per_measure
	
	var last_camera_switch:bool = not json.notes[0].mustHitSection if json.notes.size() > 0 else false
	
	for i in json.notes.size():
		var section:Dictionary = json.notes[i]
		if section == null: continue # YCE chart compat
		
		if "changeBPM" in section and section.changeBPM and float(section.bpm) > 0.0 and float(section.bpm) != cur_bpm:
			cur_bpm = float(section.bpm)
			cur_crochet = (60.0 / section.bpm) * 1000.0
		
		if last_camera_switch != section.mustHitSection:
			last_camera_switch = section.mustHitSection
			
			var event_group := ChartEventGroup.new(-99999999999.0 if cur_time <= 0.01 else cur_time, [ChartEvent.new("Camera Focus", [last_camera_switch])])
			parsed.events.append(event_group)
			
		# parse notes
		for note in section.sectionNotes:
			var parsed_note := ChartNote.new()
			parsed_note.time = float(note[0])
			parsed_note.direction = int(note[1])
			parsed_note.length = float(note[2])
			parsed_note.strumline = 1 if (!section.mustHitSection if int(note[1]) >= 4 else section.mustHitSection) else 0
			
			if note.size() > 3:
				# week 7 compat
				if note[3] is bool and note[3] == true:
					parsed_note.type = "Alt Animation"
				# psych/most other engines compat
				elif note[3] is String:
					parsed_note.type = str(note[3])
				# forever (iirc?)/older psych/random other engine support
				elif note[3] is int:
					parsed_note.type = parsed.notetypes[note[3]]
					
			parsed.notes.append(parsed_note)
			
		cur_time += cur_crochet * beats_per_measure
	
	return parsed
