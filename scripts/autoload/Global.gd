extends Node

enum VersionType {
	DEV,
	BETA,
	PRE_RELEASE,
	RELEASE
}

enum NoteDirection {
	LEFT,
	DOWN,
	UP,
	RIGHT
}

var VERSION:VersionScheme = VersionScheme.new(2, 0, 0, VersionType.DEV)
var GAME_SIZE:Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)
var SONG_NAME:String
var SONG_DIFFICULTY:String
var CHART:Chart

var EASE_FUNCS:Dictionary = {
	"cube_out": func(t:float): 
		t -= 1.0
		return 1.0 + t * t * t
}

func _ready():
	get_tree().tree_changed.connect(Overlay.get_node("Overlay")._update_scene_text)
	RenderingServer.set_default_clear_color(Color.BLACK)

func dir_to_str(dir:NoteDirection) -> String:
	return NoteDirection.keys()[dir].to_lower()
