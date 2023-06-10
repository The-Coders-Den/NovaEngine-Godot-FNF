class_name SparrowSprite extends Sprite2D

@export var atlas:SparrowAtlas

## Whether or not the animation offsets should be
## inverted like HaxeFlixel.
@export var invert_offsets:bool = false

var _frames:Dictionary = {}
var _animations:Dictionary = {}
var _current_animation:Dictionary = {}
var _anim_timer:float = 0.0

var anim_frame:int = 0
var anim_finished:bool = false
var anim_name:StringName = ""

var is_duplicate:bool = false

func _ready():
	if not atlas: return
	load_xml(atlas.xml_path)
	
func load_xml(path:String):
	texture = (texture as AtlasTexture).duplicate()
	texture.atlas = atlas.texture
	
	if not is_duplicate:
		var xml:XMLParser = XMLParser.new()
		xml.open(path)
		
		while xml.read() == OK:
			if xml.get_node_type() == XMLParser.NODE_TEXT: continue
			match xml.get_node_name():
				&"SubTexture":
					_parse_xml_subtexture(xml)
	
	texture.region = _frames.values()[0][0].frame_rect
	
	var margin:Rect2 = _frames.values()[0][0].margin
	if margin: texture.margin = margin
	
func add_anim(name:StringName, prefix:StringName, fps:int, loop:bool = true):
	if not atlas: return
	
	if name in _animations:
		push_warning("Animation %s already exists!" % name)
		return
		
	var frames:Array[Dictionary] = []
	for key in _frames.keys():
		if key != prefix: continue
		for shit in _frames[key]:
			frames.append(shit)
	
	# prefix isn't valid :(
	if frames.size() < 1:
		push_warning("Animation (name: %s, prefix: %s) couldn't be added! You might've made a typo in the prefix or it doesn't exist!" % [name, prefix])
		return
	
	_animations[name] = {
		"prefix": prefix,
		"fps": fps,
		"loop": loop,
		"frames": frames,
		"offset": Vector2.ZERO
	}

func offset_anim(name:StringName, offset:Vector2):
	if not atlas: return
	
	if not _animations.has(name) or _animations[name] == null:
		push_warning("Animation called \"%s\" doesn't exist!" % name)
		return
		
	_animations[name].offset = offset
	
func play_anim(name:StringName, force:bool = false):
	if not atlas: return
	
	if not _animations.has(name) or _animations[name] == null:
		push_warning("Animation called \"%s\" doesn't exist!" % name)
		return
	
	if force or not _current_animation.has("prefix") or _current_animation.prefix != _animations[name].prefix or anim_finished:
		anim_frame = 0
		anim_finished = false
		_anim_timer = 0.0
		
	_current_animation = _animations[name]
	anim_name = name
	offset = _current_animation.offset * (-1.0 if invert_offsets else 1.0)
	_update_anim()
		
func _process(delta:float):
	if _current_animation == null or not _current_animation.has("fps") or not atlas: return
	
	_anim_timer += delta
	if _anim_timer >= 1.0 / _current_animation.fps:
		anim_frame += 1
		if anim_frame > _current_animation.frames.size() - 1:
			if _current_animation.loop:
				anim_frame = 0
			else:
				anim_frame -= 1
				anim_finished = true
			
		_anim_timer = 0.0
		_update_anim()
		
func _update_anim():
	if not atlas: return
	var frame_data:Dictionary = _animations[anim_name].frames[anim_frame]
	
	texture.region = frame_data.frame_rect
	if frame_data.margin: texture.margin = frame_data.margin
	
func _parse_xml_subtexture(xml:XMLParser):
	if not atlas: return
	var anim_name:String = xml.get_named_attribute_value("name")
	var trimmed_anim:String = anim_name.left(len(anim_name) - 4)
	
	var frame_rect:Rect2 = Rect2(
		Vector2(
			xml.get_named_attribute_value("x").to_float(),
			xml.get_named_attribute_value("y").to_float()
		),
		Vector2(
			xml.get_named_attribute_value("width").to_float(),
			xml.get_named_attribute_value("height").to_float()
		)
	)
	
	var margin:Rect2
	if xml.has_attribute("frameX"):
		var raw_frame_x:int = xml.get_named_attribute_value("frameX").to_float()
		var raw_frame_y:int = xml.get_named_attribute_value("frameY").to_float()
		
		var raw_frame_width:int = xml.get_named_attribute_value("frameWidth").to_float()
		var raw_frame_height:int = xml.get_named_attribute_value("frameHeight").to_float()
		
		var frame_size_data:Vector2 = Vector2(
			raw_frame_width,
			raw_frame_height
		)
		if frame_size_data == Vector2.ZERO:
			frame_size_data = frame_rect.size
		
		margin = Rect2(Vector2(-raw_frame_x, -raw_frame_y),
				Vector2(raw_frame_width - frame_rect.size.x,
						raw_frame_height - frame_rect.size.y)
		)
		
		if margin.size.x < abs(margin.position.x):
			margin.size.x = abs(margin.position.x)
		if margin.size.y < abs(margin.position.y):
			margin.size.y = abs(margin.position.y)
	
	if not trimmed_anim in _frames:
		_frames[trimmed_anim] = []
	
	_frames[trimmed_anim].append({
		"frame_rect": frame_rect,
		"margin": margin
	})
