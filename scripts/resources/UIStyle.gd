class_name UIStyle extends Resource

@export_category("Ratings & Combo")
@export var rating_texture_folder:String = "res://assets/funkin/images/gui/score/default"
@export var combo_texture_folder:String = "res://assets/funkin/images/gui/score/default"
@export var rating_scale:float = 0.7
@export var combo_scale:float = 0.5

@export_category("Countdown")
@export var prepare_texture:CompressedTexture2D = preload("res://assets/funkin/images/gui/countdown/default/prepare.png")
@export var ready_texture:CompressedTexture2D = preload("res://assets/funkin/images/gui/countdown/default/ready.png")
@export var set_texture:CompressedTexture2D = preload("res://assets/funkin/images/gui/countdown/default/set.png")
@export var go_texture:CompressedTexture2D = preload("res://assets/funkin/images/gui/countdown/default/go.png")

@export var prepare_sound:AudioStream = preload("res://assets/funkin/sounds/countdown/default/intro3.ogg")
@export var ready_sound:AudioStream = preload("res://assets/funkin/sounds/countdown/default/intro2.ogg")
@export var set_sound:AudioStream = preload("res://assets/funkin/sounds/countdown/default/intro1.ogg")
@export var go_sound:AudioStream = preload("res://assets/funkin/sounds/countdown/default/introGo.ogg")
