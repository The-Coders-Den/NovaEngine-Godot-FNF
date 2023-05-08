extends Node2D
class_name Character

@export_group("General Info")
@export var is_player:bool = false
@export var sing_duration:float = 4.0
@export var dance_steps:Array[String] = ["idle"]

@export_group("Health Icon")
@export var health_icon:Texture2D = load("res://assets/images/gameplay/icons/icon-face.png")
@export var health_icon_frames:int = 2
@export var health_color:Color = Color("#A1A1A1")

@export_group("Death Screen Info")
@export var death_character:String = "bf-dead"
@export var death_sound:AudioStream = preload("res://assets/sounds/death/fnf_loss_sfx.ogg")
@export var death_music:AudioStream = preload("res://assets/music/gameOver.ogg")
@export var retry_sound:AudioStream = preload("res://assets/music/gameOverEnd.ogg")

@onready var anim_sprite:AnimatedSprite = $AnimatedSprite
@onready var anim_player:AnimationPlayer = $AnimatedSprite/AnimationPlayer

@onready var camera_pos:Node2D = $CameraPos

var special_anim:bool = false
var anim_timer:float = 0.0

var last_anim:String = "_"
var cur_dance_step:int = 0

var hold_timer:float = 0.0
var anim_finished:bool = false

var _is_true_player:bool = false
var dance_on_beat:bool = true

var initial_size:Vector2 = Vector2.ZERO

func _ready():
	anim_sprite.speed_scale = Conductor.rate
	anim_player.speed_scale = Conductor.rate
	anim_sprite.playing = false
	
	anim_player.connect("animation_finished", func(name): anim_finished = true)
	dance(true)
	
	if anim_sprite.sprite_frames:
		initial_size = Vector2(
			anim_sprite.sprite_frames.get_frame_texture(anim_sprite.animation, 0).get_width(),
			anim_sprite.sprite_frames.get_frame_texture(anim_sprite.animation, 0).get_height()
		)
	if is_player != _is_true_player:
		scale.x *= -1
		anim_sprite.position.x -= initial_size.x * absf(anim_sprite.scale.x)
	
func get_midpoint():
	return Vector2(position.x + anim_sprite.position.x + initial_size.x * 0.5, position.y + anim_sprite.position.y + initial_size.y * 0.5)
	
func get_camera_pos():
	var p:Vector2 = position + camera_pos.position
	if is_player != _is_true_player:
		p.x += 850
		
	p.x += anim_sprite.position.x
		
	return p
	
func _process(delta):
	if anim_timer > 0.0:
		anim_timer -= delta
		if anim_timer <= 0.0:
			if special_anim and last_anim == 'hey' or last_anim == 'cheer':
				special_anim = false
				dance()
			
			anim_timer = 0.0
	elif special_anim and anim_finished:
		special_anim = false
		dance()
	
	if last_anim.begins_with("sing"):
		hold_timer += delta * Conductor.rate
		if not _is_true_player and hold_timer >= Conductor.step_crochet * sing_duration * 0.0011:
			hold_timer = 0.0
			dance()

func play_anim(anim:String, force:bool = false):
	special_anim = false
	
	# swap left and right anims
	if is_player != _is_true_player:
		if anim == "singLEFT":
			anim = "singRIGHT"
		elif anim == "singRIGHT":
			anim = "singLEFT"
			
	if not anim_player.has_animation(anim):
		push_warning("Animation \""+anim+"\" doesn't exist.")
		return
		
	if force or last_anim != anim or anim_finished:
		if last_anim == anim:
			anim_player.seek(0.0)
			anim_sprite.frame = 0
			
		last_anim = anim
		anim_finished = false
		
		anim_player.play(anim)

func dance(force:bool = false):
	if special_anim and not force:
		return
		
	play_anim(dance_steps[cur_dance_step], force)
	
	cur_dance_step += 1
	if cur_dance_step > dance_steps.size() - 1:
		cur_dance_step = 0
