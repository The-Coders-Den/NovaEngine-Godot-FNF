class_name Receptor extends Node2D

@onready var sprite:AnimatedSprite2D = $Sprite
@export var direction:Tools.NoteDirection = Tools.NoteDirection.LEFT

var pressed:bool = false

func play_anim(anim:StringName):
	sprite.frame = 0
	sprite.play(anim)
