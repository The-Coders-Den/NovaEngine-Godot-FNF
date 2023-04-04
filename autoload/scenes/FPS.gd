extends CanvasLayer

@onready var label = $Label

func _process(delta):
	label.text = "FPS: "+str(Engine.get_frames_per_second())+"\n"
