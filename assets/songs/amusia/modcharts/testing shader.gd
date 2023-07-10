extends Modchart

@onready var shader:ShaderMaterial = $CanvasLayer/ColorRect.material
var TIME:float = 0.0

func _process(delta):
	TIME += delta
	var sine:float = sin(TIME * (Conductor.crochet * 0.01))
	shader.set_shader_parameter(&"multiplier", absf(sine))
