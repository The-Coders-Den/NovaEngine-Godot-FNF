class_name Note extends AnimatedSprite2D

@export var should_hit:bool = true
@export var increase_combo:bool = true
@export var play_sing_anim:bool = true
@export var health_gain_mult:float = 1.0
@export var colors:PackedColorArray = [
	Color(0.760784, 0.294118, 0.6, 1), 
	Color(0, 1, 1, 1), 
	Color(0.0705882, 0.980392, 0.0196078, 1), 
	Color(0.976471, 0.223529, 0.247059, 1)
]
@export var dynamic_note_colors:bool = false

# backend shit
@onready var splash:AnimatedSprite2D = $Splash
@onready var sustain:TextureRect = $Sustain
@onready var tail:Sprite2D = $Sustain/Tail

var time:float
var direction:int
var length:float
var strumline:StrumLine
var type:String
var scroll_speed:float = -INF
var was_already_hit:bool = false
