class_name NoteMissEvent extends CancellableEvent

## The note attached to this event.
var note:Note

## The direction of the note that was missed.
## Ranges from 0 - 3 usually.
var direction:int

## How much health you lose from missing this note.
var health_loss:float

#-- DON'T TOUCH --#
func _init(note:Note, direction:int, health_loss:float):
	self.note = note
	self.direction = direction
	self.health_loss = health_loss
