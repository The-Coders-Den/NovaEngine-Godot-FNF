extends Node2D
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

var step_crochet:float = 0.0

var note_skin:NoteSkin = Global.note_skins["default"]

@onready var game:Gameplay = $"../../../"

@onready var anim_sprite:AnimatedSprite = $AnimatedSprite
@onready var sustain:Line2D = $ColorRect/Sustain
@onready var sustain_end:Sprite2D = $ColorRect/Sustain/EndPiece

var strumline:StrumLine

func _ready():
	if length < 50: length = 0
	
	step_crochet = Conductor.step_crochet
	og_length = length
	
	anim_sprite.sprite_frames = load(note_skin.note_textures+"assets.res")
	
	sustain.points[1].y = length / (game.scroll_speed / Conductor.rate)
	sustain.texture = load(note_skin.sustain_textures+Global.note_directions[direction]+" hold piece.png")
	
	sustain_end.texture = load(note_skin.sustain_textures+Global.note_directions[direction]+" hold end.png")
	sustain_end.position.y = sustain.points[1].y + ((sustain_end.texture.get_height() * sustain_end.scale.y) * 0.5)
	
	anim_sprite.play(Global.note_directions[direction])

func _process(delta):
	if was_good_hit:
		length -= (delta * 1000.0) * Conductor.rate
		if length <= -50:
			queue_free()
			
		if must_press and not Input.is_action_pressed(strumline.controls[direction]) and length >= 150:
			was_good_hit = false
			game.fake_miss(direction)
			queue_free()
		
	var safe_zone:float = (Conductor.safe_zone_offset * (1.2 * Conductor.rate))
	if time > Conductor.position - safe_zone and time < Conductor.position + safe_zone:
		can_be_hit = true
	else:
		can_be_hit = false

	if time < Conductor.position - safe_zone and not was_good_hit and not too_late:
		too_late = true

	if too_late: modulate.a = 0.3
	
	sustain.points[1].y = ((length / 2) * (game.scroll_speed / Conductor.rate)) / scale.y
	sustain_end.position.y = sustain.points[1].y + ((sustain_end.texture.get_height() * sustain_end.scale.y) * 0.5)
