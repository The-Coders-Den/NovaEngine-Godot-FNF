class_name StrumLine extends Node2D

@onready var game:Gameplay = $"../../../../"

@onready var receptors:Node2D = $Receptors
@onready var notes:NoteGroup = $Notes

## Whether or not the notes on this strumline
## are automatically hit. Useful for botplay.
@export var autoplay:bool = false

## Whether or not the notes on this strumline
## scroll up or down.
@export var downscroll:bool = false

## The scroll speed of the notes.
## Can also be modified for every note (game.scroll_speed).
@export var scroll_speed:float = -INF

var keys_pressed:Array[bool] = []
var characters:Array[Character] = []

enum NoteDirection {
	LEFT,
	DOWN,
	UP,
	RIGHT
}

func _ready():
	for i in receptors.get_child_count():
		keys_pressed.append(false)

func prepare_anims():
	for i in receptors.get_child_count():
		var receptor:Receptor = receptors.get_child(i)
		receptor.unfuck()
		receptor.remove_child(receptor.splash)
		receptor.splash.name = "splash_%s" % str(i)
		receptor.direction = i
		add_child(receptor.splash)
		play_anim(i, "static")
		
func _dir_from_event(event:InputEventKey):
	for i in NoteDirection.keys().size():
		var dir:String = NoteDirection.keys()[i].to_lower()
		if event.is_action_pressed("note_%s" % dir) or event.is_action_released("note_%s" % dir):
			return i
		
	return -1
		
func _unhandled_key_input(event):
	if autoplay: return
	event = event as InputEventKey
	
	var dir:int = _dir_from_event(event)
	if dir == -1: return
	
	var receptor:Receptor = receptors.get_child(dir)
	receptor.pressed = event.is_pressed()
	
	if event.is_pressed():
		keys_pressed[dir] = true
		handle_note_input(dir)
	else:
		keys_pressed[dir] = false
		play_anim(dir, "static")
		
func handle_note_input(dir:int):
	var possible_notes:Array[Node] = notes.get_children().filter(func(note:Note):
		var can_be_hit:bool = (note.hit_time > Conductor.position - (Conductor.safe_zone_offset * Conductor.rate) and note.hit_time < Conductor.position + (Conductor.safe_zone_offset * 1.5 * Conductor.rate))
		var too_late:bool = (note.hit_time < Conductor.position - (Conductor.safe_zone_offset * Conductor.rate) and not note.was_already_hit)
		return note.direction == dir and can_be_hit and not too_late and not note.missed
	)
	if possible_notes.size() > 0:
		possible_notes.sort_custom(sort_hit_notes)
		
		var note:Note = possible_notes[0]
		var event := NoteHitEvent.new(note, note.direction, 0.023)
		game.call_on_modcharts("on_note_hit", [event])
		
		if not event.cancelled:
			game.good_note_hit(note, event)
			
		event.unreference()
	
	play_anim(dir, "confirm" if possible_notes.size() > 0 else "press")
	
func play_anim(dir:int, anim:String):
	var receptor = receptors.get_child(dir).sprite
	if not receptor is AnimatedSprite2D: return
	
	receptor = receptor as AnimatedSprite2D
	receptor.frame = 0
	receptor.play("%s %s" % [NoteDirection.keys()[dir].to_lower(), anim])

func sort_hit_notes(a:Note, b:Note):
	if not a.should_hit and b.should_hit: return false
	elif a.should_hit and not b.should_hit: return true
	return a.hit_time < b.hit_time
