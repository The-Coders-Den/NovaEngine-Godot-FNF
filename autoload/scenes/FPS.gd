extends CanvasLayer

var _vram_peak:float = 0.0

@onready var label = $Label

func _process(delta):
	label.text = "FPS: "+str(Engine.get_frames_per_second())+"\n"
	
	if OS.is_debug_build():
		var mem:String = Global.bytes_to_human(OS.get_static_memory_usage())
		var mem_peak:String = Global.bytes_to_human(OS.get_static_memory_peak_usage())
		label.text += mem+" / "+mem_peak+" [RAM]\n"
		
		var _vram:float = Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)
		if _vram >= _vram_peak: _vram_peak = _vram
		
		var vram:String = Global.bytes_to_human(_vram)
		var vram_peak:String = Global.bytes_to_human(_vram_peak)
		label.text += vram+" / "+vram_peak+" [VRAM]"
