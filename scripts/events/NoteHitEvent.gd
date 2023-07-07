class_name NoteHitEvent extends CancellableEvent

## The note attached to this event.
var note:Note

## The direction of the note that was hit.
## Ranges from 0 - 3 usually.
var direction:int

## How much health you gain from hitting this note.
var health_gain:float

#-- DON'T TOUCH --#
func _init(note:Note, direction:int, health_gain:float):
	self.note = note
	self.direction = direction
	self.health_gain = health_gain
