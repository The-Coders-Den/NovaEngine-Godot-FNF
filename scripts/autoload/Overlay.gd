extends MarginContainer

@onready var fps := $MainContainer/FPS
@onready var mem := $MainContainer/MEM
@onready var scene := $MainContainer/Scene

@onready var version := $VersionContainer/Version
@onready var version_type := $VersionContainer/Type

@onready var update_timer := $UpdateTimer

func _ready():
	Signals.on_scene_switch.connect(_update_scene_text)
	
	version.text = str(Global.VERSION)
	version_type.text = Global.VERSION.type_to_string()
	
	update_timer.timeout.connect(_update_text)
	update_timer.start(1.0)
	_update_text()
	_update_scene_text(get_tree().current_scene)

func _update_text():
	fps.text = "%s FPS" % str(Engine.get_frames_per_second())
	mem.text = "%s / %s" % [String.humanize_size(Performance.get_monitor(Performance.MEMORY_STATIC)), String.humanize_size(Performance.get_monitor(Performance.MEMORY_STATIC_MAX))]

func _update_scene_text(_scene:Node):
	scene.text = str(_scene.name)
