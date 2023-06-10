class_name Chart extends Resource

enum ChartType {
	NOVA,
	FNF
}

## The display name for this song.
var name:String = "Test"

var bpm:float = 150.0
var notes:Array[ChartNote] = []
var events:Array[ChartEventGroup] = []

var characters:Dictionary = {
	"opponent": PackedStringArray([]),
	"spectator": PackedStringArray([]),
	"player": PackedStringArray([]),
}

## A list of every note type in the chart.
## Only used when notes specify an int notetype.
var notetypes:PackedStringArray = []

var scroll_speed:float = 2.7
var key_count:int = 4

var beats_per_measure:float = 4.0
var steps_per_beat:float = 4.0

static func load_song(song:String, difficulty:String, type:ChartType = ChartType.FNF) -> Chart:
	var json:Dictionary = JSON.parse_string(FileAccess.open(Paths.chart_json(song, difficulty), FileAccess.READ).get_as_text())
	match type:
		ChartType.NOVA: return _parse_nova(json)
		ChartType.FNF: return _parse_fnf(json)
			
	return Chart.new()

#-- parsing functions (don't worry bout these if u makin a mod) --#
static func _parse_nova(json:Dictionary) -> Chart:
	#-- UNSUPPORTED AS OF NOW! --#
	return new()
	
static func _parse_fnf(json:Dictionary) -> Chart:
	if "song" in json and json.song is Dictionary:
		json = json.song
		
	var parsed := new()
	parsed.bpm = float(json.bpm)
	parsed.name = json.song
	parsed.scroll_speed = float(json.speed)
	parsed.characters.opponent = [json.player2]
	parsed.characters.player = [json.player1]
	parsed.characters.spectator = ["gf"]
	
	# gf shit
	if "player3" in json: parsed.characters.spectator = [json.player3]
	if "gfVersion" in json: parsed.characters.spectator = [json.gfVersion]
	if "gf" in json: parsed.characters.spectator = [json.gf]
	
	# timescale shit
	if "beatsPerMeasure" in json: parsed.beats_per_measure = float(json.beatsPerMeasure)
	if "stepsPerBeat" in json: parsed.steps_per_beat = float(json.stepsPerBeat)
		
	# stupid capitilization shit
	if "notetypes" in json: parsed.notetypes = json.notetypes
	if "noteTypes" in json: parsed.notetypes = json.noteTypes
	
	# multikey shit??
	if "keyCount" in json: parsed.key_count = json.keyCount
	if "keyNumber" in json: parsed.key_count = json.keyNumber
	
	# parse the notes and camera pans
	var cur_bpm:float = parsed.bpm
	var cur_time:float = 0.0
	var cur_crochet:float = (60.0 / parsed.bpm) * 1000.0
	var beats_per_measure:float = parsed.beats_per_measure
	
	var last_camera_switch:bool = not json.notes[0].mustHitSection if json.notes.size() > 0 else false
	
	for i in json.notes.size():
		var section:Dictionary = json.notes[i]
		if json.notes[i] == null: continue # YCE chart compat
		
		if "changeBPM" in section and section.changeBPM and float(section.bpm) > 0.0 and float(section.bpm) != cur_bpm:
			cur_bpm = float(section.bpm)
			cur_crochet = (60.0 / section.bpm) * 1000.0
		
		if last_camera_switch != section.mustHitSection:
			last_camera_switch = section.mustHitSection
			
			var event_group := ChartEventGroup.new(-99999999999.0 if cur_time <= 0.01 else cur_time, [ChartEvent.new("Camera Focus", [last_camera_switch])])
			parsed.events.append(event_group)
			
		# parse notes
		for note in section.sectionNotes:
			var parsed_note := ChartNote.new(float(note[0]), int(note[1]), float(note[2]), 1 if (!section.mustHitSection if int(note[1]) >= 4 else section.mustHitSection) else 0, "Default")
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
