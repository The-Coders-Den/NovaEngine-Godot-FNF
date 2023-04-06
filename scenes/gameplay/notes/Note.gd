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

var note_skin:UISkin = Global.ui_skins["default"]

@onready var game:Gameplay = $"../../../"

@onready var anim_sprite:AnimatedSprite = $AnimatedSprite
@onready var sustain:Line2D = $ColorRect/Sustain
@onready var sustain_end:Sprite2D = $ColorRect/Sustain/EndPiece

@onready var clip_rect:ColorRect = $ColorRect

var strumline:StrumLine

## override these functions if you need to
func _cpu_hit():
	pass
	
func _player_hit():
	pass
	
func _note_hit(is_player:bool):
	pass
	
func _cpu_miss():
	pass
	
func _player_miss():
	pass

## internal functions
func _ready():
	if length < 50: length = 0
	
	step_crochet = Conductor.step_crochet
	og_length = length
	
	if "Default" in name:
		anim_sprite.sprite_frames = load(note_skin.note_texture_path+"assets.res")
		sustain.texture = load(note_skin.sustain_texture_path+Global.note_directions[direction]+" hold piece.png")
		sustain_end.texture = load(note_skin.sustain_texture_path+Global.note_directions[direction]+" hold end.png")
		scale = Vector2(note_skin.note_scale, note_skin.note_scale)
		sustain.width /= ((note_skin.note_scale + 0.3) - note_skin.sustain_width_offset)
		texture_filter = TEXTURE_FILTER_LINEAR if note_skin.antialiasing else TEXTURE_FILTER_NEAREST
		
	clip_rect.size.y = Global.game_size.y / scale.y

	anim_sprite.play(Global.note_directions[direction])

func _process(delta):
	if was_good_hit:
		length -= (delta * 1000.0) * Conductor.rate
		if length <= -(Conductor.step_crochet):
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
	
	var downscroll_mult:int = -1 if SettingsAPI.get_setting("downscroll") else 1
	if downscroll_mult < 0:
		clip_rect.position.y = -clip_rect.size.y
		sustain.position.y = clip_rect.size.y
	else:
		clip_rect.position.y = 0
		sustain.position.y = 0
		
	sustain.points[1].y = (((length / 2.5) * (game.scroll_speed / Conductor.rate)) / scale.y) * downscroll_mult
	sustain_end.position.y = sustain.points[1].y + (((sustain_end.texture.get_height() * sustain_end.scale.y) * 0.5) * downscroll_mult)
	sustain_end.flip_v = downscroll_mult < 0
