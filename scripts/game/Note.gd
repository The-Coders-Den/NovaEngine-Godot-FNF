## base note class used for all note type
class_name Note extends Node2D
## when enabled note will sort last in the note group and opponet will not hit the note
@export var should_hit:bool = true
## when enabled you're combo will display when the note is hit
@export var display_combo_on_hit:bool = true
## when enabled you're combo will increase if the note is hit by the player
@export var increase_combo:bool = true
## when enabled you're combo will be reset to 0 but no misses will be given
@export var reset_combo_on_hit:bool = false
## when enabled the character that hits the note will play a sing anim
@export var play_sing_anim:bool = true
## health multiplier for hitting notes
@export var health_gain_mult:float = 1.0
## when enabled the note will be recolored using a shader
@export var recolor:bool = false
#-- onready --#
## cliping rectagle for sustains
@onready var sustain_clip_rect:Control = $SustainClipRect
## the sustain texturerect
@onready var sustain:TextureRect = $SustainClipRect/Sustain
## sustain end sprite
@onready var sustain_end = $SustainClipRect/Sustain/End
## note its self
@onready var sprite = $Sprite

#-- internal --#
## time to hit the note in milliseconds
var hit_time:float
## direction 0 = left and 3 = right
var direction:int
## original length of sustain
var og_length:float
## current length of sustain
var length:float
## note type name
var type:String
## strum that the note is on
var strum_line:StrumLine
## scroll speed of the note
var scroll_speed:float = -INF
## if the note was hit
var was_already_hit:bool = false
## if the note has a splash
var has_splash:bool = false
## if the note was missed
var missed:bool = false
## if the player is allowed to hit the note
var hit_allowed:bool = true
## note splash sprite
var splash:AnimatedSprite2D
