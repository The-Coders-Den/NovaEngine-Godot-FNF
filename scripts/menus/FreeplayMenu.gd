extends Node2D

# holy sweet jesus i had to space out the code so much

@export var freeplay_data:FreeplayList

@onready var camera = $Camera

@onready var template_song = $templatesong
@onready var songs = $songs
@onready var bg = $CanvasLayer/BG

@onready var diff_label = $CanvasLayer/ColorRect/diff

var color_tween:Tween
var diff:String = "hard"

var diff_index:int = 0:
	set(v):
		diff_index = wrapi(v,0,diffs.size())
		
var diffs:PackedStringArray = []

var current_song:int = 0:
	set(v):
		current_song = wrapi(v,0,freeplay_data.songs.size())

const song_spacing:float = 160.0

func _ready():
	camera.rotation_smoothing_enabled = false
	for song in freeplay_data.songs:
		if song == null:
			song = FreeplaySong.new()
			
		var new_song = template_song.duplicate()
		songs.add_child(new_song)
		new_song.name = song.song_name
		
		if not song.display_name.is_empty():
			new_song.name = song.display_name
			
		var id:int = freeplay_data.songs.find(song)
		new_song.position.x += id * 20
		new_song.position.y += song_spacing * id
		new_song.modulate.a = 0.6
		new_song.visible = true
		
		var song_text:Alphabet = new_song.get_node("text")
		var song_icon:Sprite2D = new_song.get_node("icon")
		
		song_text.text = song.song_name
		song_icon.position.x = song_text.position.x + song_text.size.x  + 75.0
		song_icon.texture = song.icon
		song_icon.hframes = song.icon_frames
		
	template_song.queue_free()
	change_song()

func _unhandled_key_input(event):
	event = event as InputEventKey
	if not event.is_pressed(): return
	
	var scroll_axis:int= -int(event.is_action_pressed("ui_up")) + int(event.is_action_pressed("ui_down"))
	var diff_axis:int = -int(event.is_action_pressed("ui_right")) + int(event.is_action_pressed("ui_left"))
	
	if scroll_axis != 0:
		change_song(scroll_axis)
		
	if diff_axis != 0:
		change_diff(diff_axis)
		
	if event.is_action_pressed("ui_accept"):
		select_song()
		
	if event.is_action_pressed("ui_cancel"):
		Global.switch_scene("res://scenes/menus/MainMenu.tscn")
	
func change_song(i:int = 0):
	songs.get_child(current_song).modulate.a = 0.6
	current_song += i
	var cur_song_shit = songs.get_child(current_song)
	cur_song_shit.modulate.a = 1.0
	
	var _song = freeplay_data.songs[current_song]
	if _song.difficulties != diffs:
		diffs = _song.difficulties
	
	camera.position.x = cur_song_shit.position.x + 620
	camera.position.y = cur_song_shit.position.y + (song_spacing * 0.45)
	camera.rotation_smoothing_enabled = true
	change_diff(0)
	
	if color_tween != null:
		color_tween.stop()
		color_tween.unreference()
		
	color_tween = create_tween()
	color_tween.tween_property(bg,"modulate",_song.color,0.5)
	
func change_diff(i:int):
	diff_index += i
	diff = diffs[diff_index]
	diff_label.text = "< %s >"%[diff]
	
func select_song():
	var _song = freeplay_data.songs[current_song]
	Gameplay.CHART = Chart.load_chart(_song.song_name.to_lower(),diff)
	Global.switch_scene("res://scenes/game/Gameplay.tscn")
