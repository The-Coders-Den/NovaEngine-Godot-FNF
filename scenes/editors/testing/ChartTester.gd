extends CanvasLayer

@onready var chart_editor = get_parent()

@onready var cpu_strums:StrumLine = $Cpu
@onready var plr_strums:StrumLine = $Plr
@onready var notes:Node2D = $Notes

@onready var info_txt = $InfoTxt

var hits:int = 0
var misses:int = 0

var note_nodes:Dictionary
var ui_skin:UISkin

var started:bool = false
var start_time:float = 0
var chart_data:Chart
var queued_notes:Array[SectionNote] = []

func _ready():
	var default_path:String = "res://scenes/gameplay/notes/Default.tscn"
	note_nodes["default"] = load(default_path).instantiate()
	note_nodes["default"].in_editor = true
	note_nodes["default"].position.y = -9999
	note_nodes["default"].process_mode = PROCESS_MODE_DISABLED
	note_nodes["Alt Animation"] = note_nodes["default"]
	
	chart_data = chart_editor.chart_data
	start_time = Conductor.position
	Conductor.position -= Conductor.crochet * 2
	
	ui_skin = load("res://scenes/gameplay/ui_skins/" + chart_data.ui_skin + ".tscn").instantiate()
	cpu_strums.note_skin = ui_skin
	plr_strums.note_skin = ui_skin
	
	for strum in cpu_strums.get_children():
		strum.animation_finished.connect(func(): \
			if strum.animation.ends_with("confirm"): \
				strum.play_anim("static") \
		)
	
	for section in chart_data.sections:
		for note in section.notes:
			if note.time < start_time: continue
			
			var note_type_path:String = "res://scenes/gameplay/notes/" + note.type + ".tscn"
			if not note.type in note_nodes and ResourceLoader.exists(note_type_path):
				note_nodes[note.type] = load(note_type_path).instantiate()
				note_nodes[note.type].in_editor = true
				note_nodes[note.type].position.y = -9999
				note_nodes[note.type].process_mode = PROCESS_MODE_DISABLED
			
			var new_note = SectionNote.new()
			new_note.time = note.time
			new_note.direction = note.direction
			new_note.length = note.length
			new_note.type = note.type
			new_note.alt_anim = note.alt_anim or note.type == "Alt Animation"
			new_note.player_section = section.is_player
			queued_notes.append(new_note)
			
	if SettingsAPI.get_setting("downscroll"):
		cpu_strums.position.y = 620
		plr_strums.position.y = 620
		info_txt.position.y = 40
			
	queued_notes.sort_custom(func(a, b): return a.time < b.time)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	while (not queued_notes.is_empty()) and queued_notes[0].time - Conductor.position < 2500:
		var note = queued_notes[0]
	
		var note_type = note.type if note.type in note_nodes else "default"
	
		var new_note = note_nodes[note.type].duplicate()
		new_note.must_press = note.player_section != (note.direction > 3)
		new_note.strumline = plr_strums if new_note.must_press else cpu_strums
		new_note.time = note.time
		new_note.direction = note.direction % 4
		new_note.length = note.length * 0.85
		new_note.note_skin = ui_skin
		new_note.note_type = note_type
		new_note.alt_anim = note.alt_anim
		
		notes.add_child(new_note)
		queued_notes.remove_at(0)
		
	if Conductor.position <= start_time:
		info_txt.text = "Prepare Yourself...\n[ESC] - Stop Testing"
		return
		
	var format_array = [
		chart_editor.float_to_minute(Conductor.position * 0.001),
		chart_editor.float_to_seconds(Conductor.position * 0.001),
		chart_editor.float_to_minute(chart_editor.track_length * 0.001),
		chart_editor.float_to_seconds(chart_editor.track_length * 0.001),
		Conductor.cur_step,
		Conductor.cur_beat,
		Conductor.cur_section,
		hits,
		misses
	]
		
	info_txt.text = "Time: %02d:%02d / %02d:%02d\nStep: %01d | Beat: %01d | Section: %01d\nHits: %01d | Misses: %01d\n[ESC] - Stop Testing" % format_array
		
func _process(delta):
	Conductor.position += delta * 1000
	Conductor._process(delta)
	
	if Conductor.position > start_time and not started:
		started = true
		for track in chart_editor.tracks:
			track.play(Conductor.position * 0.001)
	
	for note in notes.get_children():
		note_process(note, delta)
		
		var downscroll_mult:int = -1 if SettingsAPI.get_setting("downscroll") else 1
		
		var strum_line = plr_strums if note.must_press else cpu_strums
		var strum_pos:Vector2 = strum_line.get_child(note.direction).global_position
		note.position.x = strum_pos.x
		note.position.y = strum_pos.y - ((0.45 * downscroll_mult) * (Conductor.position - note.time) * chart_data.scroll_speed) * int(not note.was_good_hit)
		
		if not note.must_press and note.time <= Conductor.position:
			note.was_good_hit = true
			note.anim_sprite.visible = false
			if note.length <= 0:
				note.queue_free()
			cpu_strums.get_child(note.direction).play_anim("glow")
			
		if note.time <= Conductor.position - (500 / chart_data.scroll_speed) and not note.was_good_hit:
			note.queue_free()
			misses += 1;
		
func _unhandled_key_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()
		Conductor.position = start_time
		chart_editor.take_input = false
		chart_editor.pause(false)
		for track in chart_editor.tracks:
			track.stop()
		return
	
	var pressed = []
	var released = []
	
	for action in plr_strums.controls:
		pressed.append(event.is_action_pressed(action))
		released.append(event.is_action_released(action))
		
	for note in notes.get_children():
		if note.must_press and note.can_be_hit and pressed[note.direction]:
			note.was_good_hit = true
			note.anim_sprite.visible = false
			if note.length <= 0:
				note.queue_free()
			plr_strums.get_child(note.direction).play_anim("glow")
			hits += 1;
			break
			
	for i in pressed.size():
		var strum:Receptor = plr_strums.get_child(i)
		if pressed[i] and not strum.animation.ends_with("confirm"):
			strum.play_anim("press")
		elif released[i]:
			strum.play_anim("static")

func note_process(note:Note, delta:float):
	if note.was_good_hit:
		note.length -= (delta * 1000.0) * Conductor.rate
		if note.length <= -(Conductor.step_crochet):
			note.queue_free()
			
		if note.must_press and note.length >= 80.0 and not Input.is_action_pressed(note.strumline.controls[note.direction]):
			note.was_good_hit = false
			misses += 1;
			note.queue_free()
	
	
	var safe_zone:float = (Conductor.safe_zone_offset * (1.2 * Conductor.rate))
	note.can_be_hit = note.time > Conductor.position - safe_zone and note.time < Conductor.position + safe_zone
	
	if note.length <= 0: return
	
	note.sustain.visible = true
	note.sustain_end.visible = true
	
	var downscroll_mult:int = -1 if SettingsAPI.get_setting("downscroll") else 1
	if downscroll_mult < 0:
		note.clip_rect.position.y = -note.clip_rect.size.y
		note.sustain.position.y = note.clip_rect.size.y
	else:
		note.clip_rect.position.y = 0
		note.sustain.position.y = 0
	
	var last_point:int = note.sustain.points.size() - 1
	var scroll_speed:float = chart_data.scroll_speed
	note.sustain.points[last_point].y = (((note.length / 2.5) * (scroll_speed / Conductor.rate)) / note.scale.y) * downscroll_mult
	
	for i in note.sustain.points.size():
		if i == 0 or i == last_point:
			continue
		note.sustain.points[i].y = note.sustain.points[last_point].y * ((1.0 / note.sustain.points.size()) * i)
	
	note.sustain_end.position.y = note.sustain.points[last_point].y + (((note.sustain_end.texture.get_height() * note.sustain_end.scale.y) * 0.5) * downscroll_mult)
	note.sustain_end.flip_v = downscroll_mult < 0
