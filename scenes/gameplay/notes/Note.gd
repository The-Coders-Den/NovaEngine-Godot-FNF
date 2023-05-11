extends Node2D
class_name Note

@export var health_gain_mult:float = 1.0
@export var should_hit:bool = true

@export var time:float = 0.0:
	get:
		return time + SettingsAPI.get_setting("note offset")
		
@export var direction:int = 0
@export var length:float = 0.0

@export var in_editor:bool = false
@export var alt_anim:bool = false

var og_length:float = 0.0

# so you can do note.is_sustain_note in note hit script functions
var is_sustain_note:bool = false

var must_press:bool = false
var can_be_hit:bool = false
var was_good_hit:bool = false
var too_late:bool = false

var step_crochet:float = 0.0
var note_skin:UISkin

@onready var game:Gameplay

@onready var anim_sprite:AnimatedSprite = $AnimatedSprite
@onready var sustain:Line2D = $ColorRect/Sustain
@onready var sustain_end:Sprite2D = $ColorRect/Sustain/EndPiece

@onready var clip_rect:ColorRect = $ColorRect

var strumline:StrumLine

## override these functions if you need to
func _cpu_hit() -> void:
	pass
	
func _player_hit() -> void:
	pass
	
func _note_hit(is_player:bool) -> void:
	pass
	
func _cpu_miss() -> void:
	pass
	
func _player_miss() -> void:
	pass

## internal functions
func _ready() -> void:
	if not in_editor:
		game = $"../../../"
		note_skin = game.ui_skin
	else:
		note_skin = load("res://scenes/gameplay/ui_skins/default.tscn").instantiate()
		
	if length < 50: length = 0
	
	step_crochet = Conductor.step_crochet
	og_length = length
	
	if "Default" in name:
		anim_sprite.sprite_frames = load(note_skin.note_texture_path + "assets.res")
		
		sustain.texture = load(note_skin.sustain_texture_path + Global.note_directions[direction] + " hold piece.png")
		sustain_end.texture = load(note_skin.sustain_texture_path + Global.note_directions[direction] + " hold end.png")
		
		scale = Vector2(note_skin.note_scale, note_skin.note_scale)
		sustain.width /= ((note_skin.note_scale + 0.3) - note_skin.sustain_width_offset)
		
		texture_filter = TEXTURE_FILTER_LINEAR if note_skin.antialiasing else TEXTURE_FILTER_NEAREST
		
	if SettingsAPI.get_setting("opaque sustains"):
		sustain.modulate.a = 1.0
		
	clip_rect.size.y = Global.game_size.y / scale.y
	anim_sprite.play(Global.note_directions[direction])

func _process(delta: float) -> void:
	if was_good_hit:
		length -= (delta * 1000.0) * Conductor.rate
		if length <= -(Conductor.step_crochet):
			queue_free()
			
		if must_press and length >= 80.0 and not Input.is_action_pressed(strumline.controls[direction]):
			was_good_hit = false
			if not in_editor:
				game.fake_miss(direction)
				
			queue_free()
		
	var safe_zone:float = (Conductor.safe_zone_offset * (1.2 * Conductor.rate))
	can_be_hit = time > Conductor.position - safe_zone and time < Conductor.position + safe_zone

	too_late = time < Conductor.position - safe_zone and not was_good_hit and not in_editor

	if too_late: modulate.a = 0.3
	
	var downscroll_mult:int = -1 if SettingsAPI.get_setting("downscroll") else 1
	if downscroll_mult < 0:
		clip_rect.position.y = -clip_rect.size.y
		sustain.position.y = clip_rect.size.y
	else:
		clip_rect.position.y = 0
		sustain.position.y = 0
	
	var last_point:int = sustain.points.size() - 1
	var scroll_speed:float = game.scroll_speed if not in_editor else SettingsAPI.get_setting("scroll speed")
	sustain.points[last_point].y = (((length / 2.5) * (scroll_speed / Conductor.rate)) / scale.y) * downscroll_mult
	
	for i in sustain.points.size():
		if i == 0 or i == last_point:
			continue
		sustain.points[i].y = sustain.points[last_point].y * ((1.0 / sustain.points.size()) * i)
	
	sustain_end.position.y = sustain.points[last_point].y + (((sustain_end.texture.get_height() * sustain_end.scale.y) * 0.5) * downscroll_mult)
	sustain_end.flip_v = downscroll_mult < 0
