extends Node2D
class_name StrumLine

var is_ready:bool = false
var note_skin:UISkin = load("res://scenes/gameplay/ui_skins/" + Global.default_ui_skin + ".tscn").instantiate():
	set(v):
		note_skin = v
		
		if not is_ready: return
		update_skin()

@export var handle_input:bool = true
@export var controls:Array[String] = []

@onready var current_scene:Node = get_tree().current_scene

func _ready() -> void:
	is_ready = true
	update_skin()
		
func update_skin() -> void:
	for i in get_child_count():
		var receptor:Receptor = get_child(i)
		receptor.sprite_frames = load(note_skin.note_texture_path+"assets.res")
		receptor.play_anim("static")
		
		receptor.scale = Vector2(note_skin.note_scale, note_skin.note_scale)
		receptor.texture_filter = TEXTURE_FILTER_LINEAR if note_skin.antialiasing else TEXTURE_FILTER_NEAREST
		
		receptor.splash.sprite_frames = load(note_skin.splash_texture_path+"splashes.res")
		receptor.splash.scale = Vector2(note_skin.splash_scale, note_skin.splash_scale) / note_skin.note_scale

func _input(event:InputEvent) -> void:
	if event is InputEventKey and handle_input:
		key_shit()
		
func key_shit() -> void:
	for i in get_child_count():
		if not current_scene is Gameplay and Input.is_action_just_pressed(controls[i]):
			var receptor:Receptor = get_child(i)
			receptor.play_anim("pressed")
			
		if Input.is_action_just_released(controls[i]):
			var receptor:Receptor = get_child(i)
			receptor.play_anim("static")
