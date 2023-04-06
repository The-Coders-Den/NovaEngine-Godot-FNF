extends Node

var rate:float = 1.5
var bpm:float = 100.0

var crochet:float = ((60.0 / bpm) * 1000.0) # beats in milliseconds
var step_crochet:float = crochet / 4.0 # steps in milliseconds

var position:float = 0.0

var safe_frames:int = 10
var safe_zone_offset:float = (safe_frames / 60.0) * 1000.0

var cur_beat:int = 0
var cur_step:int = 0
var cur_section:int = 0

var cur_dec_beat:float = 0
var cur_dec_step:float = 0
var cur_dec_section:float = 0

# i am so fucking happy you can make arrays of custom resources now
var bpm_change_map:Array[BPMChangeEvent] = []

signal beat_hit(beat:int)
signal step_hit(step:int)
signal section_hit(section:int)

func map_bpm_changes(song:Chart):
	bpm_change_map = []
	var cur_bpm:float = song.bpm
	var total_steps:int = 0
	var total_pos:float = 0.0
	for i in song.sections.size():
		if song.sections[i].change_bpm and song.sections[i].bpm != cur_bpm:
			cur_bpm = song.sections[i].bpm
			var event:BPMChangeEvent = BPMChangeEvent.create(total_steps, total_pos, cur_bpm)
			bpm_change_map.append(event)
			
		var delta_steps:int = song.sections[i].length_in_steps
		total_steps += delta_steps
		total_pos += (((60.0 / cur_bpm) * 1000.0) / 4.0) * delta_steps

func change_bpm(new:float):
	bpm = new
	crochet = ((60.0 / bpm) * 1000.0)
	step_crochet = crochet / 4.0

func _process(delta):
	var old_step:int = cur_step
	var old_beat:int = cur_beat
	var old_section:int = cur_section
	
	var last_change:BPMChangeEvent = BPMChangeEvent.create(0, 0, 0)
	for i in bpm_change_map.size():
		if position >= bpm_change_map[i].song_time:
			last_change = bpm_change_map[i]
			
	cur_step = last_change.step_time + floor((position - last_change.song_time) / step_crochet)
	cur_beat = floor(cur_step / 4.0)
	cur_section = floor(cur_step / 16)

	cur_dec_step = last_change.step_time + ((position - last_change.song_time) / step_crochet)
	cur_dec_beat = cur_dec_step / 4.0
	cur_dec_section = cur_dec_step/16.0
	if old_step != cur_step && cur_step > 0: step_hit.emit(cur_step)
	if old_beat != cur_beat && cur_beat > 0: beat_hit.emit(cur_beat)
	if old_section != cur_section && cur_section > 0: section_hit.emit(cur_section)
	
func is_sound_synced(sound:AudioStreamPlayer):
	# i love windows
	var ms_allowed:float = (30 if OS.get_name() == "Windows" else 20) * sound.pitch_scale
	var sound_time:float = sound.get_playback_position() * 1000.0
	return !(absf(sound_time - position) > ms_allowed)
