class_name Note extends Node2D

@onready var sprite:AnimatedSprite2D = $Sprite

@export var should_hit:bool = true
@export var increase_combo:bool = true
@export var play_sing_anim:bool = true
@export var health_gain_mult:float = 1.0

var time:float = 0.0
var direction:int = 0
var length:float = 0.0
var type:String = "default"
var alt_anim:bool = false
var strumline:StrumLine
var was_already_hit:bool = false
