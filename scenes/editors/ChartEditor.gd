extends Control

@onready var sound_group = $sounds
@onready var hitsound = $sounds/hitsound

@onready var strum_line = $StrumLine

@onready var container = $GridContainer
@onready var player_lane = $GridContainer/PlayerLane
@onready var player_strum = $StrumLine/PlayerStrum
@onready var opponent_lane = $GridContainer/OpponentLane
@onready var opponent_strum = $StrumLine/OpponentStrum

@onready var notes_group = $NotesGroup

@onready var hover_arrow = $HoverArrow
@onready var hover_size = hover_arrow.texture.get_size()

@onready var window = get_window()

@onready var section_window:Window = $section

@onready var char_dialog:FileDialog = $CharDialog
@onready var stage_dialog:FileDialog = $StageDialog
@onready var ui_skin_dialog:FileDialog = $UISkinDialog
@onready var save_dialog:FileDialog = $SaveDialog
@onready var load_dialog:FileDialog = $LoadDialog

@onready var pos_info = $PosInfo

var hold_tex:Texture2D = preload("res://assets/images/menus/charteditor/hold.png")
var tail_tex:Texture2D = preload("res://assets/images/menus/charteditor/tail.png")
var bloom_mat:ShaderMaterial

var selected_time:float = 0
var selected_dir:int = 0
var lane_id:int = 0

var selected_note:Sprite2D
var selected_data:SectionNote 

var cur_section:int = -1 # i would of loved to used section_hit.connect but for some reason it doesnt work going backwards!
var section_start:float = 0.0
var cur_snap:float = 1

var over_left:bool = false
var over_right:bool = false

var quants:Array[int] = [4, 8, 12, 16, 20, 24, 32, 48, 64, 192]
var quant_colors:Array[Color] = [
	Color8(249, 57, 63),
	Color8(83, 107, 239),
	Color8(194, 75, 153),
	Color8(0, 229, 80),
	Color8(96, 103, 137),
	Color8(255, 122, 215),
	Color8(255, 232, 61),
	Color8(174, 54, 230),
	Color8(15, 235, 255),
	Color8(96, 103, 137)
]

var arrow_rotations:Array[float] = [0, 270, 90, 180]

var tracks:Array[AudioPlayer] = []

var chart_data:Chart = Global.SONG
var track_length:float = 100000;

func load_song():
	var music_path:String = "res://assets/songs/%s/audio/" % chart_data.name.to_lower()
	
	if DirAccess.dir_exists_absolute(music_path):
		var dir = DirAccess.open(music_path)
		
		for file in dir.get_files():
			var music:AudioPlayer = AudioPlayer.new()
			for f in Global.audio_formats:
				if file.ends_with(f + ".import"):
					music.stream = load(music_path + file.replace(".import",""))
					music.pitch_scale = Conductor.rate
					tracks.append(music)
					sound_group.add_child(music)
	
	if tracks.is_empty():
		printerr("The tracks list of this song is empty! Did you specify the right folder?")
		Audio.play_sound("cancelMenu")

func _init(): # doing it on init because doing it on ready causes a crash on "Run Current Scene"
	if chart_data == null:
		chart_data = Chart.load_chart("bopeebo","hard")
		Global.SONG = chart_data

func _ready():
	load_song()
	track_length = tracks[0].stream.get_length() * 1000 if (not tracks.is_empty()) else 10;
	
	Conductor.position = 0
	Conductor.cur_section = 0
	Conductor.map_bpm_changes(chart_data)
	# regen_notes() not calling it on ready because PlayerLane's x is not set yet.
	
	bloom_mat = ShaderMaterial.new()
	bloom_mat.shader = load("res://assets/shaders/NoteBloom.gdshader")

func get_quant_color(hit_time:float):
	var measure_time:float = 60 / Conductor.bpm * 1000 * 4
	var smallest_deviation:float = measure_time / quants[quants.size() - 1]
	
	for quant in quants.size():
		var quant_time:float = (measure_time / quants[quant])
		if fmod(hit_time - section_start + smallest_deviation, quant_time) < smallest_deviation * 2:
			return quant_colors[quant]

func regen_notes():
	cur_section = Conductor.cur_section
	selected_note = null
	selected_data = null
	
	while chart_data.sections.size() <= cur_section: # If you go too far, it will add sections to prevent a null error.
		var new_section = Section.new()
		new_section.bpm = Conductor.bpm
		chart_data.sections.append(new_section)
		
	var cur_bpm = chart_data.bpm;
	section_start = 0.0;
	for i in cur_section:
		if chart_data.sections[i].change_bpm:
			cur_bpm = chart_data.sections[i].bpm
		section_start += 60 / cur_bpm * 4000;
	Conductor.change_bpm(cur_bpm if not chart_data.sections[cur_section].change_bpm else chart_data.sections[cur_section].bpm); # The for loop doesn't account for the current section.
		
	while notes_group.get_child_count() > 0:
		var note = notes_group.get_child(0)
		note.queue_free()
		notes_group.remove_child(note)
	
	for note_data in chart_data.sections[cur_section].notes:
		var note = Sprite2D.new()
		notes_group.add_child(note)
		note.texture = hover_arrow.texture
		note.scale = Vector2(0.275, 0.275)
		var use_opp = (note_data.direction % 8 < 4) != chart_data.sections[cur_section].is_player
		var lane_to_place = opponent_lane if use_opp else player_lane
		note.rotation_degrees = arrow_rotations[note_data.direction % 4]
				
		note.modulate = get_quant_color(note_data.time)
		
		note.position.x = (container.position.x + lane_to_place.position.x) + note_data.direction % 4 * (lane_to_place.size.x / 4) + (lane_to_place.size.x / 64) + hover_size.x * 0.275 * 0.5
		note.position.y = container.position.y + (note_data.time - section_start) / Conductor.step_crochet * (container.size.y / 16) + hover_size.y * 0.275 * 0.5

		add_sustain(note)
		if note_data.length > 0:
			var hold:Line2D = note.get_child(0)
			hold.points[1].y = ((note_data.length / Conductor.step_crochet * container.size.y / 16) - container.size.y / 16) / 0.275
			var tail = hold.get_child(0)
			tail.position.y = hold.points[1].y + tail_tex.get_height() * 0.5
			tail.visible = true
			
	section_window.on_regen()

func add_sustain(note:Sprite2D):
	var line = Line2D.new()
	line.texture = hold_tex
	line.width = 50
	line.points = [
		Vector2(0, 0),
		Vector2(0, 0)
	]
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.rotation_degrees = -note.rotation_degrees
	line.show_behind_parent = true
	line.use_parent_material = true
	note.add_child(line)
	
	var tail = Sprite2D.new()
	tail.texture = tail_tex
	tail.position.y = line.points[1].y + tail_tex.get_height() * 0.5
	tail.use_parent_material = true
	line.add_child(tail)

func check_note():
	for i in chart_data.sections[Conductor.cur_section].notes.size():
		var note_data = chart_data.sections[Conductor.cur_section].notes[i]
		
		if note_data.time == selected_time and note_data.direction == selected_dir:
			var note = notes_group.get_child(i)
			if Input.is_key_label_pressed(KEY_CTRL):
				if selected_note != null:
					selected_note.material = null
				selected_note = note
				selected_data = note_data
				note.material = bloom_mat
			else:
				if selected_note == note:
					selected_note = null
					selected_data = null
					
				note.queue_free()
				chart_data.sections[Conductor.cur_section].notes.remove_at(i)
			return true
	return false

func _input(event):
	if char_dialog.visible or stage_dialog.visible or ui_skin_dialog.visible or save_dialog.visible or load_dialog.visible: return
	
	var hold_axis = Input.get_axis("chart_hold_down", "chart_hold_up")
	if event is InputEventKey and (event.is_action_pressed("chart_hold_down") or event.is_action_pressed("chart_hold_up")) and selected_note != null:
		var hold_inc:float = Conductor.step_crochet * hold_axis * cur_snap
		selected_data.length = clampf(selected_data.length + hold_inc, 0, 999999)
		
		var hold:Line2D = selected_note.get_child(0)
		hold.visible = selected_data.length > 0.0
		if hold.visible:
			hold.points[1].y = ((selected_data.length / Conductor.step_crochet * container.size.y / 16) - container.size.y / 16) / 0.275
			var tail = hold.get_child(0)
			tail.position.y = hold.points[1].y + tail_tex.get_height() * 0.5
	
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT and event.pressed \
	and hover_arrow.visible and not check_note():
		var new_note = hover_arrow.duplicate()
		new_note.modulate.a = 1
		notes_group.add_child(new_note)
		add_sustain(new_note)
		
		var note_data = SectionNote.new()
		note_data.time = selected_time
		note_data.direction = selected_dir
		chart_data.sections[Conductor.cur_section].notes.append(note_data)
		
		if selected_note != null:
			selected_note.material = null
		selected_note = new_note
		selected_data = note_data
		new_note.material = bloom_mat

func play_song():
	if tracks.is_empty() or Conductor.position >= track_length: return
	
	if !tracks[0].playing:
		for track in tracks:
			track.play(Conductor.position / 1000)
	else:
		for track in tracks:
			track.stop()

func _process(delta):
	if char_dialog.visible or stage_dialog.visible or ui_skin_dialog.visible or save_dialog.visible or load_dialog.visible: return
	
	if Input.is_key_label_pressed(KEY_ESCAPE) or Input.is_key_label_pressed(KEY_ENTER):
		Global.switch_scene("res://scenes/gameplay/Gameplay.tscn")
		return
	
	if Input.is_action_just_pressed("space_bar"):
		play_song()
	
	strum_line.position.y = container.position.y + (Conductor.position - section_start) / (Conductor.step_crochet) * (container.size.y / 16)
	
	var mouse_pos = window.get_mouse_position()
	over_left = opponent_lane.get_global_rect().has_point(mouse_pos)
	over_right = player_lane.get_global_rect().has_point(mouse_pos)

	hover_arrow.visible = over_left or over_right
	if hover_arrow.visible:
		var snapped_step = floorf((mouse_pos.y - container.position.y) / (container.size.y / 16) / cur_snap)
		selected_time = section_start + (Conductor.step_crochet * (snapped_step * cur_snap))
		hover_arrow.position.y = container.position.y + (selected_time - section_start) / Conductor.step_crochet * (container.size.y / 16) + hover_size.y * 0.275 * 0.5
	
		var cur_lane:Panel = opponent_lane if over_left else player_lane
		var x_pos = cur_lane.position.x + container.position.x
		lane_id = floor((mouse_pos.x - x_pos) / (cur_lane.size.x / 4))
		selected_dir = lane_id + 4 * int(over_right != chart_data.sections[Conductor.cur_section].is_player)

		hover_arrow.rotation_degrees = arrow_rotations[lane_id]
		hover_arrow.position.x = x_pos + lane_id * (cur_lane.size.x / 4) + (cur_lane.size.x / 64) + hover_size.x * 0.275 * 0.5
		hover_arrow.modulate = get_quant_color(selected_time)
		hover_arrow.modulate.a = 0.5

	var mult:float = 4 if Input.is_action_pressed("shift_key") else 1
	
	var vert_axis = Input.get_axis("ui_up", "ui_down");
	var hori_axis = Input.get_axis("ui_left", "ui_right");
	
	if (not tracks.is_empty()) and tracks[0].playing:
		Conductor.position = tracks[0].time
	elif vert_axis != 0:
		Conductor.position += delta * 500 * mult * vert_axis
	elif Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		Conductor.position += Conductor.crochet * 4 * mult * hori_axis
	Conductor.position = clampf(Conductor.position, 0, track_length);
	
	if cur_section != Conductor.cur_section:
		regen_notes()
		
	var format_array = [
		float_to_minute(Conductor.position * 0.001),
		float_to_seconds(Conductor.position * 0.001),
		float_to_minute(track_length * 0.001),
		float_to_seconds(track_length * 0.001),
		Conductor.cur_step,
		Conductor.cur_beat,
		Conductor.cur_section
	]
		
	pos_info.text = "%02d:%02d / %02d:%02d\n\nStep: %01d\nBeat: %01d\nSection: %01d" % format_array

# thanks @BeastlyGabi for letting me use these lol.
func float_to_minute(value:float): return int(value / 60)
func float_to_seconds(value:float): return fmod(value, 60)
