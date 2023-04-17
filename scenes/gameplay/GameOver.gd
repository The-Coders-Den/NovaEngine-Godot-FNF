extends Node2D
class_name GameOver

@onready var camera:Camera2D = $Camera2D
@onready var death_music:AudioStreamPlayer = $DeathMusic
@onready var death_sound:AudioStreamPlayer = $DeathSound
@onready var retry_sound:AudioStreamPlayer = $RetrySound

@onready var fade:ColorRect = $CanvasLayer/Fade

var character:Character

func _ready():
	camera.position = Global.death_camera_pos
	camera.zoom = Global.death_camera_zoom
	
	character = load("res://scenes/gameplay/characters/"+Global.death_character+".tscn").instantiate()
	character.position = Global.death_char_pos
	character._is_true_player = true
	add_child(character)
	
	character.play_anim("firstDeath")
	
	death_music.stream = Global.death_music
	death_sound.stream = Global.death_sound
	retry_sound.stream = Global.retry_sound
	
	death_sound.pitch_scale = Conductor.rate
	death_sound.play()
	
var is_following_already:bool = false
var is_ending:bool = false

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Global.switch_scene("res://scenes/StoryMenu.tscn" if Global.is_story_mode else "res://scenes/FreeplayMenu.tscn")
		
	if Input.is_action_just_pressed("ui_accept"):
		end_bullshit()
		
	if character.last_anim == "firstDeath" and character.anim_sprite.frame >= 12 and not is_following_already:
		is_following_already = true
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = Conductor.rate
		camera.position = character.get_camera_pos()
		
	if character.last_anim == "firstDeath" and character.anim_finished:
		cool_start_death()

func cool_start_death(volume:float = 1.0):
	if is_ending: return
	
	death_music.volume_db = linear_to_db(volume)
	death_music.pitch_scale = Conductor.rate
	death_music.stream.loop = true
	death_music.play()
	
	character.play_anim("deathLoop", true)
	
func end_bullshit():
	if is_ending: return
	is_ending = true
	
	death_music.stop()
	
	retry_sound.pitch_scale = Conductor.rate
	retry_sound.play()
	
	character.play_anim("deathConfirm", true)
	
	await get_tree().create_timer(0.7 / Conductor.rate).timeout
	
	var tween:Tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 2.0 / Conductor.rate)
	tween.tween_callback(func(): Global.switch_scene("res://scenes/gameplay/Gameplay.tscn"))
