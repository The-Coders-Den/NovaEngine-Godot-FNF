extends Node

class BPMChangeEvent extends Resource:
	var step:float = 0
	var time:float = 0.0
	var bpm:float = 100.0

	func _init(_step:float = 0, _time:float = 0, _bpm:float = 0):
		self.step = _step
		self.time = _time
		self.bpm = _bpm

var rate:float = 1:
	set(v):
		Engine.time_scale = v
		rate = v
	
var bpm:float = 100.0

var crochet:float = ((60.0 / bpm) * 1000.0) # beats in milliseconds
var step_crochet:float = crochet / 4.0 # steps in milliseconds

var position:float = 0.0

var safe_frames:int = 10
var safe_zone_offset:float = (safe_frames / 60.0) * 1000.0

var beats_per_measure:float = 4.0
var steps_per_beat:float = 4.0

var cur_beat:int = 0
var cur_step:int = 0
var cur_measure:int = 0

var cur_dec_beat:float = 0
var cur_dec_step:float = 0
var cur_dec_measure:float = 0

var bpm_change_map:Array[BPMChangeEvent] = []

signal beat_hit(beat:int)
signal step_hit(step:int)
signal measure_hit(measure:int)

func map_bpm_changes(song:Chart):
	bpm_change_map = []
	if song.events == null or song.events.size() < 1: return
	
	var cur_bpm:float = song.bpm
	var time:float = 0
	var step:float = 0
	
	for group in song.events:
		for event in group.events:
			if event.name != "BPM Change" or event.parameters == null or event.parameters.size() < 1:
				continue
				
			if float(event.parameters[0]) == cur_bpm:
				continue
				
			var steps:float = (group.time - time) / ((60.0 / cur_bpm) * 1000.0 / beats_per_measure)
			step += steps
			time = group.time
			cur_bpm = float(event.parameters[0])
			
			bpm_change_map.append(BPMChangeEvent.new(step, time, cur_bpm))

func change_bpm(new:float, _beats_per_measure:float = 4, _steps_per_beat:float = 4):
	bpm = new
	crochet = ((60.0 / new) * 1000.0)
	step_crochet = crochet / 4.0
	
	Conductor.beats_per_measure = _beats_per_measure
	Conductor.steps_per_beat = _steps_per_beat
	
func setup_song(chart:Chart):
	change_bpm(chart.bpm, chart.beats_per_measure, chart.steps_per_beat)
	map_bpm_changes(chart)

func _process(_delta):
	var bpm_change:BPMChangeEvent = BPMChangeEvent.new(0, 0, 0)
	for event in Conductor.bpm_change_map:
		if position >= event.time:
			bpm_change = event
			break
			
	if bpm_change.bpm > 0 and bpm != bpm_change.bpm: change_bpm(bpm_change.bpm)
	
	var old_step:int = cur_step
	var old_beat:int = cur_beat
	var old_measure:int = cur_measure
	
	cur_dec_step = bpm_change.step + (position - bpm_change.time) / step_crochet
	cur_step = floor(cur_dec_step)
	
	cur_dec_beat = cur_dec_step / steps_per_beat
	cur_beat = floor(cur_dec_beat)
	
	cur_dec_measure = cur_dec_beat / beats_per_measure
	cur_measure = floor(cur_dec_measure)

	if old_step != cur_step: step_hit.emit(cur_step)
	if old_beat != cur_beat: beat_hit.emit(cur_beat)
	if old_measure != cur_measure: measure_hit.emit(cur_measure)
