class_name NoteMissEvent extends CancellableEvent

## The note attached to this event.
var note:Note

## The direction of the note that was missed.
## Ranges from 0 - 3 usually.
var direction:int

## How much health you lose from missing this note.
var health_loss:float

#-- DON'T TOUCH --#
func _init(_note:Note, _direction:int, _health_loss:float):
	self.note = _note
	self.direction = _direction
	self.health_loss = _health_loss
