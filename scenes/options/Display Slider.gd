extends OptionSlider
class_name DisplaySlider

@export var decimals:int = 10
@export var suffix:String = ""
@onready var display:Label = $Display

func _ready():
	super._ready()
	display.text = str(value).pad_decimals(decimals)+suffix

func _on_value_changed(value:float):
	super._on_value_changed(value)
	display.text = str(value).pad_decimals(decimals)+suffix
