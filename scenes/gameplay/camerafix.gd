extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	offset.x = -640 + (-640 * (1 - zoom.x))
	offset.y = -360 + (-360 * (1 - zoom.y))

	anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
