extends MusicBeatScene

@export var week_list:Array[StoryWeek] = []

var cur_week:int = 0
# var lerp_score:int = 0
var selected_week:bool = false

var cur_chars:PackedStringArray = ["", "", ""]
var char_sprites = [null, null, null]

var cur_diff:int = 1
var left_x:float = 915
var diff_x:float = 970
var right_x:float = 1191

@onready var week_group:Node2D = $WeekGroup
@onready var char_group:Node2D = $Characters

@onready var bf_pos:Node2D = $CharacterPositions/Player
@onready var gf_pos:Node2D = $CharacterPositions/Specator
@onready var dad_pos:Node2D = $CharacterPositions/Opponent

@onready var tracklist:Label = $TrackList
@onready var score_count:Label = $TopBG/ScoreCount
@onready var week_name:Label = $TopBG/WeekName

@onready var left_arrow:AnimatedSprite = $LeftArrow
@onready var right_arrow:AnimatedSprite = $RightArrow
@onready var diff_sprite:Sprite2D = $Difficulty

func _ready():
	Audio.play_music("freakyMenu")
	
	for i in week_list.size():
		var week_sprite:WeekSprite = WeekSprite.new()
		week_sprite.position.x = 640
		week_sprite.texture = week_list[i].week_texture
		week_sprite.position.y = 480 - week_sprite.texture.get_height()
		week_group.add_child(week_sprite)
	
	if SettingsAPI.get_setting("story always yellow"):
		$ColoredBG.color = Color("#f9cf51")
	change_week(0)

func _process(delta):
	var lerp_val:float = clamp(delta * 60 * 0.3, 0, 1)
	left_arrow.position.x = lerp(left_arrow.position.x, left_x, lerp_val)
	diff_sprite.position.x = lerp(diff_sprite.position.x, diff_x, lerp_val)
	diff_sprite.offset.y = lerp(diff_sprite.offset.y, 0.0, lerp_val)
	diff_sprite.modulate.a = 1 + diff_sprite.offset.y / 20
	right_arrow.position.x = lerp(right_arrow.position.x, right_x, lerp_val)
	
	if selected_week:
		return
		
	if Input.is_action_just_pressed("switch_mod"):
		add_child(load("res://scenes/ModsMenu.tscn").instantiate())
	
	if Input.is_action_just_pressed("ui_up"):
		change_week(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_week(1)
		
	if Input.is_action_just_pressed("ui_left"):
		change_diff(-1)
		
	if Input.is_action_just_pressed("ui_right"):
		change_diff(1)
		
	if Input.is_action_pressed("ui_left"):
		left_arrow.anim_player.play("push")
	else:
		left_arrow.anim_player.play("idle")
		
	if Input.is_action_pressed("ui_right"):
		right_arrow.anim_player.play("push")
	else:
		right_arrow.anim_player.play("idle")
		
	if Input.is_action_just_pressed("ui_cancel"):
		selected_week = true
		Audio.play_sound("cancelMenu")
		Global.switch_scene("res://scenes/MainMenu.tscn")
		
	if Input.is_action_just_pressed("ui_accept"):
		select_week()

func change_week(inc):
	Audio.play_sound("scrollMenu")
	
	cur_week = wrap(cur_week + inc, 0, week_list.size())
	
	var char_pos = [dad_pos, bf_pos, gf_pos]
	var chars_to_add = [week_list[cur_week].opponent, week_list[cur_week].player, week_list[cur_week].specator]

	for i in week_group.get_child_count():
		var week_sprite:WeekSprite = week_group.get_child(i)
		week_sprite.target_y = i - cur_week
		week_sprite.modulate.a = 1.0 if cur_week == i else 0.6
		
	tracklist.text = "TRACKS\n\n"
	for i in week_list[cur_week].songs.size():
		tracklist.text += week_list[cur_week].songs[i].display_name.to_upper() + "\n"
		
	week_name.text = week_list[cur_week].name.to_upper()
	
	if !SettingsAPI.get_setting("story always yellow"):
		get_tree().create_tween().tween_property($ColoredBG, "color", week_list[cur_week].bg_color, 0.5)
	
	for i in 3:
		var old_char = char_sprites[i]
		if old_char != null and cur_chars[i] != chars_to_add[i]:
			char_group.remove_child(old_char)
			old_char.queue_free()
		if (old_char == null or cur_chars[i] != chars_to_add[i]):
			make_char(chars_to_add[i], char_pos[i], 0.9 if i == 1 else 0.5, i)
			
	cur_chars = chars_to_add
	
	change_diff(0)
	
func change_diff(inc:int):
	cur_diff = wrap(cur_diff + inc, 0, week_list[cur_week].difficulties.size())
	
	var diff_tex = load("res://assets/images/menus/storymenu/difficulties/" + week_list[cur_week].difficulties[cur_diff] + ".png")
	diff_sprite.texture = diff_tex
	diff_sprite.position.y = left_arrow.position.y + left_arrow.sprite_frames.get_frame_texture(left_arrow.animation.replace(" push", ""), 0).get_height() / 2 - diff_tex.get_height() / 2
	diff_sprite.offset.y = -20
	
	reposition_diff()
	
func make_char(name:String, pos_node:Node2D, scale:float, index:int):
	var char_path:String = "res://scenes/story_chars/" + name + ".tscn"
	var char:Node2D
	if ResourceLoader.exists(char_path):
		char = load(char_path).instantiate()
	else:
		print("UNABLE TO FIND TSCN FILE: \"" + char_path + "\"\nTHE GAME WILL INSTEAD ADD AN EMPTY NODE.")
		var node = Node2D.new()
		char_sprites[index] = node
		char_group.add_child(node)
		return
	var anim_sprite:AnimatedSprite = char.get_child(0)
	anim_sprite.anim_player.play("idle")
	var frame_size = anim_sprite.sprite_frames.get_frame_texture(anim_sprite.animation, 0).get_size()
	frame_size.x *= anim_sprite.scale.x
	frame_size.y *= anim_sprite.scale.y
	char.position.x = pos_node.position.x - frame_size.x * scale / 2
	char.position.y = pos_node.position.y - frame_size.y * scale
	char.scale.x = scale
	char.scale.y = scale
	char_group.add_child(char)
	
	char_sprites[index] = char

func reposition_diff():
	left_x = 640 + week_group.get_child(cur_week).texture.get_width() / 2 + 20
	var left_width = left_arrow.sprite_frames.get_frame_texture(left_arrow.animation.replace(" push", ""), 0).get_width()
	diff_x = left_x + left_width + 10
	right_x = diff_x + diff_sprite.texture.get_width() + 10

func select_week():
	selected_week = true
	week_group.get_child(cur_week).flashing = true
	Audio.play_sound("confirmMenu")
	for old_i in 3:
		var i = 2 - old_i
		var char = char_group.get_child(i)
		var anim_sprite:AnimatedSprite = char.get_child(0)
		if anim_sprite != null and anim_sprite.anim_player.has_animation("confirm"):
			anim_sprite.anim_player.play("confirm")
	
	Global.is_story_mode = true
	Global.queued_songs = []
	Global.current_difficulty = week_list[cur_week].difficulties[cur_diff]
	Global.SONG = Chart.load_chart(week_list[cur_week].songs[0].song_path, Global.current_difficulty)
	for i in week_list[cur_week].songs.size(): # The worst way to do it but... im dumb.
		if i > 0:
			Global.queued_songs.append(week_list[cur_week].songs[i].song_path)
	await get_tree().create_timer(1).timeout
	Global.switch_scene("res://scenes/gameplay/Gameplay.tscn")
