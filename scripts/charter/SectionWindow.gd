extends Window

@onready var chart_editor = get_parent()

@onready var player_cam:CheckBox = $Panel/ScrollContainer/VBoxContainer/PlayerCam
@onready var bpm_check:CheckBox = $Panel/ScrollContainer/VBoxContainer/BpmCheck
@onready var bpm_spin:SpinBox = $Panel/ScrollContainer/VBoxContainer/BPMSpin
@onready var cam_dym:OptionButton = $Panel/ScrollContainer/VBoxContainer/CamDynamic
@onready var last_spin:SpinBox = $Panel/ScrollContainer/VBoxContainer/LastSpin

var cur_section:int = -1
var copied_notes:Array[SectionNote] = []
var copied_must_hit:bool = false

func on_regen():
	if cur_section == Conductor.cur_section: return
	cur_section = Conductor.cur_section
	
	player_cam.set_pressed_no_signal(chart_editor.chart_data.sections[cur_section].is_player)
	bpm_check.set_pressed_no_signal(chart_editor.chart_data.sections[cur_section].change_bpm)
	bpm_spin.set_value_no_signal(Conductor.bpm)

func _set_cam_target(toggled:bool):
	chart_editor.chart_data.sections[Conductor.cur_section].is_player = toggled
	
	for note in chart_editor.chart_data.sections[Conductor.cur_section].notes: 
		note.direction = (note.direction + 4) % 8 # Fixes an invisible section swap.
		
func _set_change_bpm(toggled:bool):
	chart_editor.chart_data.sections[Conductor.cur_section].change_bpm = toggled
	
	chart_editor.chart_data.sections[Conductor.cur_section].bpm = bpm_spin.value
	Conductor.map_bpm_changes(chart_editor.chart_data) # This feels dumb to do but its the only way to fix it.

	chart_editor.regen_notes()
	
func _set_bpm(new_bpm:float):
	if not chart_editor.chart_data.sections[Conductor.cur_section].change_bpm: return
	
	chart_editor.chart_data.sections[Conductor.cur_section].bpm = new_bpm
	
	Conductor.map_bpm_changes(chart_editor.chart_data) # This feels dumb to do but its the only way to fix it.
	chart_editor.regen_notes()
	
func _copy_section():
	copied_notes.clear()
	copied_must_hit = chart_editor.chart_data.sections[Conductor.cur_section].is_player
	
	for note in chart_editor.chart_data.sections[Conductor.cur_section].notes:
		var new_note = SectionNote.new()
		
		new_note.time = note.time - chart_editor.section_start
		new_note.direction = note.direction
		new_note.length = note.length
		new_note.type = note.type
		new_note.alt_anim = note.alt_anim
		new_note.player_section = note.player_section
		
		copied_notes.append(new_note)
		
func _paste_section():
	if copied_notes.is_empty(): return
	
	chart_editor.chart_data.sections[Conductor.cur_section].notes.clear()
	var cur_must_hit = chart_editor.chart_data.sections[Conductor.cur_section].is_player
	
	for note in copied_notes:
		var new_note = SectionNote.new()
		
		new_note.time = note.time + chart_editor.section_start
		new_note.direction = note.direction
		if cur_must_hit != copied_must_hit and cam_dym.selected % 2 == 0:
			new_note.direction = (note.direction + 4) % 8
		new_note.length = note.length
		new_note.type = note.type
		new_note.alt_anim = note.alt_anim
		new_note.player_section = note.player_section
		
		chart_editor.chart_data.sections[Conductor.cur_section].notes.append(new_note)
	chart_editor.regen_notes()

func _copy_last_section():
	var last_bpm = chart_editor.chart_data.bpm;
	var last_start = 0.0;
	for i in Conductor.cur_section - last_spin.value:
		if chart_editor.chart_data.sections[i].change_bpm:
			last_bpm = chart_editor.chart_data.sections[i].bpm
		last_start += 60 / last_bpm * 4000;
	
	chart_editor.chart_data.sections[Conductor.cur_section].notes.clear()
	var last_must_hit = chart_editor.chart_data.sections[Conductor.cur_section - last_spin.value].is_player
	var cur_must_hit = chart_editor.chart_data.sections[Conductor.cur_section].is_player
	
	for note in chart_editor.chart_data.sections[Conductor.cur_section - last_spin.value].notes:
		var new_note = SectionNote.new()
		
		new_note.time = note.time - last_start + chart_editor.section_start
		new_note.direction = note.direction
		if cur_must_hit != last_must_hit and cam_dym.selected < 2:
			new_note.direction = (note.direction + 4) % 8
		new_note.length = note.length
		new_note.type = note.type
		new_note.alt_anim = note.alt_anim
		new_note.player_section = note.player_section
		
		chart_editor.chart_data.sections[Conductor.cur_section].notes.append(new_note)
	chart_editor.regen_notes()

func _swap_section():
	for note in chart_editor.chart_data.sections[Conductor.cur_section].notes:
		note.direction = (note.direction + 4) % 8
	chart_editor.regen_notes()

func _clear_section():
	chart_editor.chart_data.sections[Conductor.cur_section].notes.clear()
	chart_editor.regen_notes()
