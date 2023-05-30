extends Panel
enum ujashjkdfsa{
	PISS
}
# VARIABLES #
@onready var sprite_data:AnimatedSprite2D = $"../SpriteData"
@onready var fps_box:LineEdit = $FPS

var path:StringName = "res://Assets/Images/Characters/bf/assets"
var fps:int = 24
var looped:bool = false
var optimized:bool = true

func convert_xml() -> void:
	if path == "":
		return
	
	var base_path:StringName = path.get_basename()
	var texture:Texture = load(base_path + ".png")
	
	if texture == null:
		print(base_path + " loading failed.")
		return
	
	var frames:SpriteFrames = SpriteFrames.new()
	frames.remove_animation("default")
	var file:String = FileAccess.open(base_path + ".json",FileAccess.READ).get_as_text()
	var json = JSON.parse_string(file)
	for shit in json.frames:
		var json_frame_data = json.frames[shit].frame
		
		var anim_name:String = shit
		
		anim_name = anim_name.left(anim_name.length() - 4)
		
		var frame:AtlasTexture = AtlasTexture.new()
		
		frame.atlas = load(base_path + ".png")
		
		var frame_rect:Rect2 = Rect2(json_frame_data.x,json_frame_data.y,json_frame_data.w,json_frame_data.h)
		
		frame.region = frame_rect
		frame.filter_clip = true
		var frame_src_rect = json.frames[shit].spriteSourceSize
		
		var margin = Rect2(Vector2(frame_src_rect.x, frame_src_rect.y),
						Vector2(frame_src_rect.w - frame_rect.size.x,
						frame_src_rect.h - frame_rect.size.y))
						
		if margin.size.x < abs(margin.position.x):
			margin.size.x = abs(margin.position.x)
		if margin.size.y < abs(margin.position.y):
			margin.size.y = abs(margin.position.y)
		frame.margin = margin
						
		if not frames.has_animation(anim_name):
			frames.add_animation(anim_name)
			frames.set_animation_loop(anim_name,looped)
			frames.set_animation_speed(anim_name,fps)
			
		frames.add_frame(anim_name,frame)
			
	
	
	sprite_data.frames = frames
	
	var previous_atlas:AtlasTexture
	var previous_rect:Rect2
	
	ResourceSaver.save(frames, base_path + ".res", ResourceSaver.FLAG_COMPRESS)
	
	var framerate_multiplier:float = (1.0 / fps)
	
	for anim in frames.animations:
		sprite_data.play(anim.name)
		
		await get_tree().create_timer(framerate_multiplier * frames.get_frame_count(anim.name))\
				.timeout

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _process(delta:float) -> void:
	pass
#	if Input.is_action_just_pressed("ui_cancel") and not fps_box.has_focus():
#		Global.switch_scene("res://scenes/MainMenu.tscn")

# funny signal shits
func set_path(new_path:StringName) -> void:
	path = new_path

func set_fps(new_fps:StringName) -> void:
	fps = new_fps.to_int()

func set_looped(new_looped:bool) -> void:
	looped = new_looped

func set_optimized(new_optimized:bool) -> void:
	optimized = new_optimized
