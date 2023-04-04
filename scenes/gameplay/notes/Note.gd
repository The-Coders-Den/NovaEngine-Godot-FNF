extends AnimatedSprite
class_name Note

@export var health_gain_mult:float = 1.0
@export var should_hit:bool = true

var time:float = 0.0
var direction:int = 0
var length:float = 0.0
var og_length:float = 0.0

var must_press:bool = false
var can_be_hit:bool = false
var was_good_hit:bool = false
var too_late:bool = false

var strumline:StrumLine

func _ready():
	og_length = length
	play(Global.note_directions[direction])

func _process(delta):
	if time > Conductor.position - Conductor.safe_zone_offset and time < Conductor.position + (Conductor.safe_zone_offset * (1.2 * Conductor.rate)):
		can_be_hit = true
	else:
		can_be_hit = false

	if time < Conductor.position - Conductor.safe_zone_offset and not was_good_hit and not too_late:
		too_late = true

	if too_late: modulate.a = 0.3
