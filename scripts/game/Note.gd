class_name Note extends Node2D

@export var should_hit:bool = true
@export var increase_combo:bool = true
@export var play_sing_anim:bool = true
@export var health_gain_mult:float = 1.0

@onready var sustain_clip_rect:ReferenceRect = $SustainClipRect
@onready var sustain:TextureRect = $SustainClipRect/Sustain
@onready var sustain_end = $SustainClipRect/Sustain/End
@onready var sprite = $Sprite

#-- internal --#
var hit_time:float
var direction:int
var og_length:float
var length:float
var type:String
var strum_line:StrumLine
var scroll_speed:float = -INF
var was_already_hit:bool = false
var has_splash:bool = false
var missed:bool = false
var splash:AnimatedSprite2D
