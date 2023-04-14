extends MusicBeatScene

var cur_selected:int = 0
var cur_difficulty:int = 1

var intended_score:int = 0
var lerp_score:float = 0.0

@export var song_list:FreeplaySongList = FreeplaySongList.new()

@onready var bg:Sprite2D = $bg
@onready var songs:CanvasGroup = $Songs
@onready var song_template:FreeplayAlphabet = $__TemplateSong__

@onready var score_bg:ColorRect = $ScoreBG
@onready var score_text:Label = $ScoreText
@onready var diff_text:Label = $DiffText

func _ready():
	super._ready()
	Audio.play_music("freakyMenu")
	Conductor.change_bpm(Audio.music.stream.bpm)

	for i in song_list.songs.size():
		var meta:FreeplaySong = song_list.songs[i]
		
		var song:FreeplayAlphabet = song_template.duplicate()
		var icon:HealthIcon = song.get_node("HealthIcon")
		song.text = meta.display_name if meta.display_name != null and len(meta.display_name) > 0 else meta.song
		icon.texture = meta.character_icon
		icon.hframes = meta.icon_frames
		icon.position.x = song.size.x + 80
		song.position = Vector2(0, (70 * i) + 30)
		song.visible = true
		song.is_menu_item = true
		song.target_y = i
		songs.add_child(song)
		
	change_selection()
	position_highscore()
		
func change_selection(change:int = 0):
	cur_selected = wrapi(cur_selected + change, 0, song_list.songs.size())
	
	for i in songs.get_child_count():
		var song:FreeplayAlphabet = songs.get_child(i)
		song.target_y = i - cur_selected
		song.modulate.a = 1.0 if cur_selected == i else 0.6
		
	Audio.play_sound("scrollMenu")
	change_difficulty()
		
func change_difficulty(change:int = 0):
	var diff_amount:int = song_list.songs[cur_selected].difficulties.size()
	cur_difficulty = wrapi(cur_difficulty + change, 0, diff_amount)
	var diff_name:String = song_list.songs[cur_selected].difficulties[cur_difficulty].to_upper()
	
	intended_score = HighScore.get_score(song_list.songs[cur_selected].song,diff_name) # unimplemented
	diff_text.text = "< "+diff_name+" >" if diff_amount > 0 else diff_name
	
	position_highscore()
	
	
func position_highscore():
	score_text.text = "PERSONAL BEST:"+str(floor(lerp_score))
	
	score_text.position.x = Global.game_size.x - score_text.size.x - 6
	score_bg.scale.x = Global.game_size.x - score_text.position.x + 6
	score_bg.position.x = Global.game_size.x - score_bg.scale.x
	diff_text.position.x = score_bg.position.x + score_bg.scale.x / 2
	diff_text.position.x -= diff_text.size.x / 2

func _process(delta):
	bg.modulate = lerp(bg.modulate, song_list.songs[cur_selected].bg_color, delta * 60 * 0.045)
	
	lerp_score = lerpf(lerp_score, intended_score, clampf(delta * 60 * 0.4, 0.0, 1.0))
	position_highscore()
	
	if Input.is_action_just_pressed("ui_up"):
		change_selection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_selection(1)
		
	if Input.is_action_just_pressed("ui_left"):
		change_difficulty(-1)
		
	if Input.is_action_just_pressed("ui_right"):
		change_difficulty(1)
	
	if Input.is_action_just_pressed("ui_accept"):
		Global.queued_songs = []
		Global.is_story_mode = false
		Global.current_difficulty = song_list.songs[cur_selected].difficulties[cur_difficulty]
		Global.SONG = Chart.load_chart(song_list.songs[cur_selected].song, Global.current_difficulty)
		Global.switch_scene("res://scenes/gameplay/Gameplay.tscn")
		
	if Input.is_action_just_pressed("ui_cancel"):
		Audio.play_sound("cancelMenu")
		Global.switch_scene("res://scenes/MainMenu.tscn")
