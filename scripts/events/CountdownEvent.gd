class_name CountdownEvent extends CancellableEvent

## How many times the countdown has ticked.
var tick:int

## The sprite displayed.
var sprite:Sprite2D

## The sound heard.
var sound:AudioStreamPlayer

## The tween attached to the sprite.
var tween:Tween

func _init(tick:int, sprite:Sprite2D, sound:AudioStreamPlayer, tween:Tween):
	self.tick = tick
	self.sprite = sprite
	self.sound = sound
	self.tween = tween
