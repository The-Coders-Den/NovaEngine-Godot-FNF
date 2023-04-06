extends MusicBeatScene

var cur_selected:int = 0

@export var song_list:FreeplaySongList = FreeplaySongList.new()

@onready var bg:Sprite2D = $bg
@onready var songs:CanvasGroup = $Songs
@onready var song_template:FreeplayAlphabet = $__TemplateSong__

func _ready():
	super._ready()
	Audio.play_music("freakyMenu")
	Conductor.change_bpm(Audio.music.stream.bpm)
	
	for i in song_list.songs.size():
		var meta:FreeplaySong = song_list.songs[i]
		
		var song:FreeplayAlphabet = song_template.duplicate()
		var icon:HealthIcon = song.get_node("HealthIcon")
		song.text = meta.display_name
		icon.texture = meta.character_icon
		icon.hframes = meta.icon_frames
		icon.position.x = song.size.x + 70
		song.position = Vector2(0, (70 * i) + 30)
		song.visible = true
		song.is_menu_item = true
		song.target_y = i
		songs.add_child(song)
		
	change_selection()
		
func change_selection(change:int = 0):
	cur_selected = wrapi(cur_selected + change, 0, song_list.songs.size())
	
	for i in songs.get_child_count():
		var song:FreeplayAlphabet = songs.get_child(i)
		song.target_y = i - cur_selected
		song.modulate.a = 1.0 if cur_selected == i else 0.6
		
	Audio.play_sound("scrollMenu")

func _process(delta):
	bg.modulate = lerp(bg.modulate, song_list.songs[cur_selected].bg_color, delta * 60 * 0.045)
	
	if Input.is_action_just_pressed("ui_up"):
		change_selection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_selection(1)
	
	if Input.is_action_just_pressed("ui_accept"):
		Audio.stop_music()
		Global.SONG = Chart.load_chart(song_list.songs[cur_selected].song, "hard")
		Global.switch_scene("res://scenes/gameplay/Gameplay.tscn")
		
	if Input.is_action_just_pressed("ui_cancel"):
		Audio.play_sound("cancelMenu")
		Global.switch_scene("res://scenes/MainMenu.tscn")
