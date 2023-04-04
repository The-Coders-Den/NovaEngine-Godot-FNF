extends Node2D
class_name Character

@export var sing_duration:float = 4.0
@export var dance_steps:Array[String] = ["idle"]

@export var health_icon:Texture2D = load("res://assets/images/gameplay/icons/icon-face.png")
@export var health_icon_frames:int = 2
@export var health_color:Color = Color("#A1A1A1")

@onready var anim_sprite:AnimatedSprite = $AnimatedSprite
@onready var anim_player:AnimationPlayer = $AnimatedSprite/AnimationPlayer

var last_anim:String = "_"
var cur_dance_step:int = 0

var hold_timer:float = 0.0
var anim_finished:bool = false

func _ready():
	anim_sprite.speed_scale = Conductor.rate
	anim_player.speed_scale = Conductor.rate
	anim_sprite.playing = false
	
	anim_player.connect("animation_finished", func(name): anim_finished = true)
	dance(true)
	
func _process(delta):
	if last_anim.begins_with("sing"):
		hold_timer += delta
		if hold_timer >= Conductor.step_crochet * sing_duration * 0.0011:
			hold_timer = 0
			dance()

func play_anim(anim:String, force:bool = false):
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

func dance(force:bool = true):
	play_anim(dance_steps[cur_dance_step])
	
	cur_dance_step += 1
	if cur_dance_step > dance_steps.size() - 1:
		cur_dance_step = 0
