extends CanvasLayer

var show_extra_info:bool = false
var _vram_peak:float = 0.0

var _update_timer:float = 0.0

@onready var fps_label:Label = $FPSLabel
@onready var mem_label:Label = $MEMLabel

func _ready():
	update_text(true)
	mem_label.visible = show_extra_info

func _physics_process(delta):
	visible = SettingsAPI.get_setting("fps counter")
	
	if Input.is_action_just_pressed("show_extra_info"):
		show_extra_info = not show_extra_info
		mem_label.visible = show_extra_info
		
	_update_timer += delta
	
	if _update_timer >= 1.0:
		_update_timer = 0.0
		update_text()
		
func update_text(force_update_mem:bool = false):
	fps_label.text = "FPS: "+str(Engine.get_frames_per_second())
	
	if OS.is_debug_build() and (show_extra_info or force_update_mem):
		var mem:String = Global.bytes_to_human(OS.get_static_memory_usage())
		var mem_peak:String = Global.bytes_to_human(OS.get_static_memory_peak_usage())
		mem_label.text = mem+" / "+mem_peak+" [RAM]\n"
		
		var _vram:float = Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)
		if _vram >= _vram_peak: _vram_peak = _vram
		
		var vram:String = Global.bytes_to_human(_vram)
		var vram_peak:String = Global.bytes_to_human(_vram_peak)
		mem_label.text += vram+" / "+vram_peak+" [VRAM]\n"
		
		mem_label.text += "\n--------== Conductor Info == --------\n"
		
		mem_label.text += "BPM: "+str(Conductor.bpm)+"\n"
		mem_label.text += "Rate: "+str(Conductor.rate)+"\n"
		mem_label.text += "Position: "+str(Conductor.position)+"\n"
		mem_label.text += "Crochet: "+str(Conductor.crochet)+"\n"
		mem_label.text += "Step Crochet: "+str(Conductor.step_crochet)+"\n"
		mem_label.text += "Current Beat: "+str(Conductor.cur_beat)+"\n"
		mem_label.text += "Current Step: "+str(Conductor.cur_step)+"\n"
		mem_label.text += "Current Measure/Section: "+str(Conductor.cur_section)+"\n"

		mem_label.text += "\n---------== Engine Info == ----------\n"
		
		mem_label.text += "Objects: "+str(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))+"\n"
		mem_label.text += "Process Time: "+str(Performance.get_monitor(Performance.TIME_PROCESS))+"\n"
		mem_label.text += "Physics Process Time: "+str(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS))+"\n"

		mem_label.text += "\n---------== System Info == ----------\n"
		
		var distro:String = " ("+OS.get_distribution_name()+")" if OS.get_distribution_name() != OS.get_name() else ""
		mem_label.text += "OS: "+OS.get_name()+distro+"\n"
		mem_label.text += "OS Version: "+OS.get_version()+"\n"
		mem_label.text += "CPU: "+OS.get_processor_name()+"\n"
		mem_label.text += "GPU: "+RenderingServer.get_rendering_device().get_device_name()+"\n"
		mem_label.text += "Audio Latency: "+str(Performance.get_monitor(Performance.AUDIO_OUTPUT_LATENCY))+"\n"
