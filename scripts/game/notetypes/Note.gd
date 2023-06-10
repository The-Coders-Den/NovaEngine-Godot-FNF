class_name Note extends AnimatedSprite2D

@export var should_hit:bool = true
@export var increase_combo:bool = true
@export var play_sing_anim:bool = true
@export var health_gain_mult:float = 1.0

var time:float
var direction:int
var length:float
var strumline:StrumLine
var type:String
var scroll_speed:float = -INF
var was_already_hit:bool = false
