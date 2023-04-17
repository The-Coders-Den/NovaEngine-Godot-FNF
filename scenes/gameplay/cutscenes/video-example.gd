extends Cutscene
@onready var video = $video

func _ready():
	video.finished.connect(_end)
	video.play()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		_end()
