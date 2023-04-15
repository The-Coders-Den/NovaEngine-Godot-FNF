extends Resource
class_name Chart

var name:String = "Test"
var bpm:float = 150.0
var sections:Array[Section] = []
var key_count:int = 4
var scroll_speed:float = 1.0

var opponent:String = "bf"
var spectator:String = "gf"
var player:String = "bf"

var stage:String = "stage"
var ui_skin:String = "default"

static func load_chart(song:String, difficulty:String = "normal"):
	var json = JSON.parse_string(FileAccess.open("res://assets/songs/"+song+"/"+difficulty+".json", FileAccess.READ).get_as_text()).song
	
	var chart = new()
	chart.name = json.song
	chart.bpm = json.bpm
	chart.key_count = 4
	chart.scroll_speed = json.speed
	
	if "keyCount" in json:
		chart.key_count = json.keyCount
		
	if "keyNumber" in json:
		chart.key_count = json.keyNumber
		
	if "mania" in json:
		match json.mania:
			1: chart.key_count = 6
			2: chart.key_count = 7
			3: chart.key_count = 9
			_: chart.key_count = 4
			
	if "stage" in json:
		chart.stage = json.stage
		
	chart.opponent = json.player2
	chart.player = json.player1
	
	if "opponent" in json:
		chart.spectator = json.opponent
		
	if "player" in json:
		chart.spectator = json.player
	
	if "gfVersion" in json and json.gfVersion != null:
		chart.spectator = json.gfVersion
		
	if "gf" in json and json.gf != null:
		chart.spectator = json.gf
		
	if "player3" in json and json.player3 != null:
		chart.spectator = json.player3
		
	if "spectator" in json:
		chart.spectator = json.spectator
		
	if "uiSkin" in json:
		chart.ui_skin = json.uiSkin
	
	# oh god wish me luck converting these
	# damn base game sections to cool ones!
	
	for section in json.notes:
		var cool_section:Section = Section.new()
		cool_section.bpm = section.bpm if "bpm" in section and section.bpm != null else 0.0
		cool_section.change_bpm = section.changeBPM if "changeBPM" in section and section.changeBPM != null else false
		cool_section.is_player = section.mustHitSection if "mustHitSection" in section and section.mustHitSection != null else true
		cool_section.length_in_steps = section.lengthInSteps if "lengthInSteps" in section and section.lengthInSteps != null else 16
		cool_section.notes = []
		
		# convermting the noite!
		for note in section.sectionNotes:
			var cool_note:SectionNote = SectionNote.new()
			cool_note.time = float(note[0])
			cool_note.direction = int(note[1])
			cool_note.length = float(note[2])
			
			# stunpid note tpye handletation
			if note.size() > 3:
				match note[3]:
					# week 7 charts (real)
					true:
						cool_note.type = "Alt Animation"
						
					# psych and other engine charts (some use ints but if they do fuck you)
					_:
						if note[3] is String:
							cool_note.type = note[3]
						else:
							cool_note.type = "default"
			else:
				cool_note.type = "default"
				
			cool_note.alt_anim = section.altAnim if "altAnim" in section and section.altAnim != null else false
			cool_section.notes.append(cool_note)
		
		# push section  !
		chart.sections.append(cool_section)
	
	return chart
