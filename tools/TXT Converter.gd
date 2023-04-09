extends Panel

# VARIABLES #
@onready var sprite_data = $"../SpriteData"
@onready var fps_box = $FPS

var path: String = "res://Assets/Images/Characters/bf/assets"
var fps: int = 24
var looped: bool = false
var optimized: bool = true

func convert_xml():
	if path != "":
		var path_string:String
		
		if path.ends_with(".png") or path.ends_with(".txt"):
			path_string = path.left(len(path) - 4)
		else:
			path_string = path
		
		var texture = load(path_string + ".png")
		
		if texture != null:
			var frames = SpriteFrames.new()
			
			var txt = FileAccess.open(path_string + ".txt", FileAccess.READ)
			
			sprite_data.frames = frames
			
			var lines = txt.get_as_text().split("\n")
			
			for line in lines:
				if line != "":
					var data = line.split("=")
					
					var animation_name = data[0].split("_")[0]
					
					var sprite_data:PackedStringArray = data[1].split(" ")
					sprite_data.remove_at(0)
					
					var frame_rect = Rect2(
						Vector2(
							int(sprite_data[0]),
							int(sprite_data[1])
						),
						Vector2(
							int(sprite_data[2]),
							int(sprite_data[3])
						)
					)
					
					var frame_data = AtlasTexture.new()
					frame_data.atlas = texture
					frame_data.region = frame_rect
					frame_data.filter_clip = true
					
					if !frames.has_animation(animation_name):
						frames.add_animation(animation_name)
						frames.set_animation_loop(animation_name, false)
						frames.set_animation_speed(animation_name, 24)
					
					frames.add_frame(animation_name, frame_data)
			
			frames.remove_animation("default")
			ResourceSaver.save(frames, path_string + ".res", ResourceSaver.FLAG_COMPRESS)
			
			for anim in frames.animations:
				sprite_data.play(anim.name)
				await get_tree().create_timer((1.0 / frames.get_animation_speed(anim.name)) * frames.get_frame_count(anim.name)).timeout
		else:
			print(path_string + " loading failed.")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") and not fps_box.has_focus():
		Global.switch_scene("res://scenes/MainMenu.tscn")

# funny signal shits
func set_path(new_path: String):
	path = new_path
	print(new_path)

func set_fps(new_fps: String):
	fps = new_fps.to_int()

func set_looped(new_looped: bool):
	looped = new_looped

func set_optimized(new_optimized: bool):
	optimized = new_optimized
