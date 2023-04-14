extends CanvasLayer

var options:PackedStringArray = [
	"Resume",
	"Restart Song",
	"Change Options",
	"Exit To Menu"
]
var cur_selected:int = 0

var music_volume:float = 0.0
var final_volume:float = 0.5

@onready var bg:ColorRect = $BG
@onready var text_template:FreeplayAlphabet = $__TemplateSong__
@onready var menu_items:Node2D = $MenuItems
@onready var game:Gameplay = $"../"
@onready var music:AudioStreamPlayer = $Music
@onready var song_name:Label = $SongName
@onready var difficulty:Label = $Difficulty

func _ready():
	get_tree().paused = true
	
	music.volume_db = -80
	music.play(randf_range(0.0, music.stream.get_length() * 0.5))
	
	for i in options.size():
		var option:String = options[i]
		
		var new_item:FreeplayAlphabet = text_template.duplicate()
		new_item.position = Vector2(0, (70 * i) + 30)
		new_item.text = option
		new_item.is_menu_item = true
		new_item.target_y = i
		new_item.visible = true
		menu_items.add_child(new_item)
		
	change_selection()
		
	song_name.modulate.a = 0.0
	difficulty.modulate.a = 0.0
	
	song_name.text = Global.SONG.name
	difficulty.text = Global.current_difficulty.to_upper()
	
	await get_tree().create_timer(0.05).timeout
	
	song_name.position.x = Global.game_size.x - (song_name.size.x + 10)
	difficulty.position.x = Global.game_size.x - (difficulty.size.x + 10)

	var bg_tween:Tween = create_tween()
	bg_tween.tween_property(bg, "modulate:a", 0.6, 0.4)
	bg_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	
	var tween:Tween = create_tween().set_parallel()
	tween.tween_property(song_name, "modulate:a", 1, 0.4).set_delay(0.3)
	tween.tween_property(song_name, "position:y", song_name.position.y + 5, 0.4).set_delay(0.3)
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	
	var tween2:Tween = create_tween().set_parallel()
	tween2.tween_property(difficulty, "modulate:a", 1, 0.4).set_delay(0.5)
	tween2.tween_property(difficulty, "position:y", difficulty.position.y + 5, 0.4).set_delay(0.5)
	tween2.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	
func change_selection(change:int = 0):
	cur_selected = wrapi(cur_selected + change, 0, options.size())
	
	for i in menu_items.get_child_count():
		var item:FreeplayAlphabet = menu_items.get_child(i)
		item.target_y = i - cur_selected
		item.modulate.a = 1.0 if cur_selected == i else 0.6
		
	Audio.play_sound("scrollMenu")

func _process(delta):
	music_volume = clampf(music_volume + (0.01 * delta), 0.0, final_volume)
	music.volume_db = linear_to_db(music_volume)
				
	if Input.is_action_just_pressed("ui_accept"):
		match options[cur_selected]:
			"Resume":
				get_tree().paused = false
				queue_free()
				
			"Restart Song":
				Global.reset_scene()
				queue_free()
				
			"Change Options":
				Audio.play_music("freakyMenu")
				
				Global.scene_arguments["options_menu"].exit_scene_path = "res://scenes/gameplay/Gameplay.tscn"
				Global.switch_scene("res://scenes/OptionsMenu.tscn")
				queue_free()
				
			"Exit To Menu":
				# no stororey mode  yet!
				Audio.play_music("freakyMenu")
				
				Global.queued_songs = []
				Global.switch_scene("res://scenes/FreeplayMenu.tscn" if !Global.is_story_mode else "res://scenes/StoryMenu.tscn")
				queue_free()
	
	if Input.is_action_just_pressed("ui_up"):
		change_selection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_selection(1)
