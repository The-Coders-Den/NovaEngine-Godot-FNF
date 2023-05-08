extends HSlider
class_name DisplaySliderOptionless

@export var decimals:int = 10
@export var suffix:String = ""
@onready var display:Label = $Display

func _ready():
	display.text = str(value).pad_decimals(decimals)+suffix

func _on_value_changed(value:float):
	display.text = str(value).pad_decimals(decimals)+suffix
