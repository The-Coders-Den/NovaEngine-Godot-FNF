extends CanvasLayer

var show_extra_info:bool = false
var _vram_peak:float = 0.0

var _update_timer:float = 0.0

@onready var fps_label:Label = $FPSLabel

func _ready():
	update_text()

func _physics_process(delta):
	visible = SettingsAPI.get_setting("fps counter")
	
	if Input.is_action_just_pressed("show_extra_info"):
		show_extra_info = not show_extra_info
		update_text()
		
	_update_timer += delta
	
	if _update_timer >= 1.0:
		_update_timer = 0.0
		update_text()
		
func update_text():
	var vram:float = Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)
	var ram:float = Performance.get_monitor(Performance.MEMORY_STATIC)
	fps_label.text = "FPS - %s\n" %str(Engine.get_frames_per_second())
	
	if OS.is_debug_build() and show_extra_info:
		fps_label.text += "STATIC RAM - %s\n" % String.humanize_size(ram)
		fps_label.text += "VRAM - %s\n" % String.humanize_size(vram)
		fps_label.text += "OBJECTS - %s\n" %Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
		fps_label.text += "AUDIO LATENCY - %sMS\n"%(AudioServer.get_output_latency()*1000.0)

