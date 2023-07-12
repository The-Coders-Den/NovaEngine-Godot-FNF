extends Node2D
@onready var camera = $Camera

@export var freeplay_data:FreeplayList
@onready var templatesong = $templatesong
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
const song_spaceing:float = 160.0

# Called when the node enters the scene tree for the first time.
func _ready():
	camera.rotation_smoothing_enabled = false
	for song in freeplay_data.songs:
		if song == null:
			song = FreeplaySong.new()
		print(song.bpm)
		var new_song = templatesong.duplicate()
		songs.add_child(new_song)
		new_song.name = song.song_name
		if not song.display_name.is_empty():
			new_song.name = song.display_name
		new_song.position.y += song_spaceing * freeplay_data.songs.find(song)
		new_song.visible = true
		var song_text:Alphabet = new_song.get_node("text")
		song_text.text = song.song_name
		var song_icon:Sprite2D = new_song.get_node("icon")
		song_icon.position.x = song_text.position.x + song_text.size.x  + 75.0
		song_icon.texture = song.icon
		song_icon.hframes = song.icon_frames
	templatesong.queue_free()
	change_song()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func _unhandled_key_input(event):
	event = event as InputEventKey
	if not event.is_pressed(): return
	var scroll_axis:int = Input.get_axis("ui_up","ui_down")
	var diff_axis:int = Input.get_axis("ui_left","ui_right")
	if scroll_axis != 0:
		change_song(scroll_axis)
	if diff_axis != 0:
		change_diff(diff_axis)
	if Input.is_action_just_pressed("ui_accept"):
		select_song()
	
func change_song(i:int = 0):
	current_song += i
	var _song = freeplay_data.songs[current_song]
	if _song.difficulties != diffs:
		diffs = _song.difficulties
	print(diffs)
	camera.position.y = current_song*song_spaceing
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
	get_tree().change_scene_to_file("res://scenes/game/Gameplay.tscn")
