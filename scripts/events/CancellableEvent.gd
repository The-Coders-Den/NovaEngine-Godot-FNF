class_name CancellableEvent extends Resource

## Whether or not this event has been cancelled.
var cancelled:bool = false

## Cancels this event.
func cancel():
	cancelled = true
