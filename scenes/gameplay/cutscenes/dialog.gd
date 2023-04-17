extends Cutscene
@onready var panel = $Panel
@export var texts:Array[String] = []
var text_index:int = -1
@onready var text_lab = $Panel/text

func next_dialog():
	text_index += 1
	if text_index >= texts.size():
		_end()
		return
	text_lab.text = texts[text_index]

func open_box():
	next_dialog()
	var t:Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(panel,"size:x",1000,0.5)
	print("piss")

func _process(delta):
	panel.set_offsets_preset(Control.PRESET_CENTER_BOTTOM,Control.PRESET_MODE_KEEP_SIZE,16)
	if Input.is_key_pressed(KEY_F1):
		_end()
	if Input.is_action_just_pressed("ui_accept"):
		next_dialog()

func _ready():
	panel.size.x = 0
	open_box()
