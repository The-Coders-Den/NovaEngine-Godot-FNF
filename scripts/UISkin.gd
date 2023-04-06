extends Node
class_name UISkin

@export_group("Texture Paths")

@export_dir var note_texture_path:String = "res://assets/images/gameplay/notes/default/"
@export_dir var sustain_texture_path:String = "res://assets/images/gameplay/notes/default/sustains/"
@export_dir var splash_texture_path:String = "res://assets/images/gameplay/notes/default/"

@export_dir var rating_texture_path:String = "res://assets/images/gameplay/score/default/"
@export_dir var combo_texture_path:String = "res://assets/images/gameplay/score/default/"

@export_group("Textures")

@export var ready_texture:CompressedTexture2D = preload("res://scenes/gameplay/countdown/default/ready.png")
@export var set_texture:CompressedTexture2D = preload("res://scenes/gameplay/countdown/default/set.png")
@export var go_texture:CompressedTexture2D = preload("res://scenes/gameplay/countdown/default/go.png")

@export_group("Scaling")

@export var note_scale:float = 0.7
@export var splash_scale:float = 1.0
@export var sustain_width_offset:float = 0.0

@export var rating_scale:float = 0.7
@export var combo_scale:float = 0.5
@export var countdown_scale:float = 1.0

@export_group("Filtering")

@export var antialiasing:bool = true
@export var splash_antialiasing:bool = true

@export var rating_antialiasing:bool = true
@export var combo_antialiasing:bool = true
@export var countdown_antialiasing:bool = true

@export_group("Sounds")

@export var prepare_sound:AudioStream = preload("res://assets/sounds/countdown/default/intro3.ogg")
@export var ready_sound:AudioStream = preload("res://assets/sounds/countdown/default/intro2.ogg")
@export var set_sound:AudioStream = preload("res://assets/sounds/countdown/default/intro1.ogg")
@export var go_sound:AudioStream = preload("res://assets/sounds/countdown/default/introGo.ogg")
