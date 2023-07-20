extends Window

@onready var chart_data:Chart:
	get:
		return get_parent().chart_data

@onready var save_dialog = $"../SaveDialog"
@onready var load_dialog = $"../LoadDialog"

@onready var switch_buttons = [
	$"../assets/Panel/ScrollContainer/VBoxContainer/Player/SwitchButton",
	$"../assets/Panel/ScrollContainer/VBoxContainer/Opponent/SwitchButton",
	$"../assets/Panel/ScrollContainer/VBoxContainer/Spectator/SwitchButton",
	$"../assets/Panel/ScrollContainer/VBoxContainer/Stage/SwitchButton",
	$"../assets/Panel/ScrollContainer/VBoxContainer/UISkin/SwitchButton",
	$"Panel/ScrollContainer/VBoxContainer/SaveSong",
	$"Panel/ScrollContainer/VBoxContainer/ReloadAudio",
	$"Panel/ScrollContainer/VBoxContainer/LoadJSON"
]

@onready var song_name = $Panel/ScrollContainer/VBoxContainer/SongName
@onready var bpm = $Panel/ScrollContainer/VBoxContainer/BPM
@onready var scroll_speed = $Panel/ScrollContainer/VBoxContainer/ScrollSpeed

func _ready():
	song_name.text = chart_data.name
	bpm.value = chart_data.bpm
	scroll_speed.value = chart_data.scroll_speed
	pass

func enable_switches():
	for button in switch_buttons:
		button.disabled = false

func disable_switches():
	for button in switch_buttons:
		button.disabled = true

func _save_song(path:String):
	var save_json:Dictionary = {
		"song": chart_data.name,
		"bpm": chart_data.bpm,
		"speed": chart_data.scroll_speed,
		
		"player1": chart_data.player,
		"player2": chart_data.opponent,
		"gfVersion": chart_data.spectator,
		
		"stage": chart_data.stage,
		"uiSkin": chart_data.ui_skin,
		
		"notes": []
	}
	
	var cur_bpm = chart_data.bpm
	
	for section in chart_data.sections:
		if section.change_bpm:
			cur_bpm = section.bpm
		
		var da_section:Dictionary = {
			"altAnim": false,
			"mustHitSection": section.is_player,
			"lengthInSteps": section.length_in_steps,
			"changeBPM": section.change_bpm,
			"bpm": cur_bpm,
			"sectionNotes": []
		}
		
		for note in section.notes:
			var da_type = "Alt Animation" if note.alt_anim and note.type == "default" else note.type
			var section_note = [note.time, note.direction, note.length]
			if da_type != "default":
				section_note.append(da_type)
			da_section["sectionNotes"].append(section_note)
			
		save_json["notes"].append(da_section)
		
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"song": save_json}, "\t"))
	file.close()
		
	enable_switches()

func _open_save():
	save_dialog.popup_centered()
	disable_switches()

func _load_song(path:String):
	var song = path.get_slice("/", path.get_slice_count("/") - 2)
	var diff = path.get_file().get_basename()
	
	Global.SONG = Chart.load_chart(song, diff)
	Global.switch_scene("res://scenes/editors/ChartEditor.tscn")

func _open_load():
	load_dialog.popup_centered()
	disable_switches()

func _song_name_changed(new_text:String):
	chart_data.name = new_text
	
func _bpm_changed(new_value:float):
	chart_data.bpm = new_value
	
func _speed_changed(new_value:float):
	chart_data.scroll_speed = new_value

func _reload_audio():
	var chart_editor = get_parent()
	for sound in chart_editor.tracks:
		sound.playing = false
		sound.queue_free()
	chart_editor.tracks.clear()
	chart_editor.load_song()
	chart_editor.track_length = chart_editor.tracks[0].stream.get_length() * 1000 if (not chart_editor.tracks.is_empty()) else 0;
