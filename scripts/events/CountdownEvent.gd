class_name CountdownEvent extends CancellableEvent

## How many times the countdown has ticked.
var tick:int

## The sprite displayed.
var sprite:Sprite2D

## The sound heard.
var sound:AudioStreamPlayer

## The tween attached to the sprite.
var tween:Tween

func _init(_tick:int, _sprite:Sprite2D, _sound:AudioStreamPlayer, _tween:Tween):
	self.tick = _tick
	self.sprite = _sprite
	self.sound = _sound
	self.tween = _tween
