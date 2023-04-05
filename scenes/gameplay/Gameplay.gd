extends MusicBeatScene
class_name Gameplay

var template_notes:Dictionary = {
	"default": preload("res://scenes/gameplay/notes/Default.tscn").instantiate()
}
var OPPONENT_HEALTH_COLOR:StyleBoxFlat = preload("res://assets/styles/healthbar/opponent.tres")
var PLAYER_HEALTH_COLOR:StyleBoxFlat = preload("res://assets/styles/healthbar/player.tres")

var SONG:Chart = Global.SONG
var note_data_array:Array[SectionNote] = []

var starting_song:bool = true
var ending_song:bool = false

var scroll_speed:float = 2.7

var health:float = 1.0:
	set(v):
		health = clampf(v, 0.0, max_health)
		
var max_health:float = 2.0

var score:int = 0
var misses:int = 0
var combo:int = 0

var accuracy_pressed_notes:int = 0.0
var accuracy_total_hit:float = 0.0

var stage:Stage
var opponent:Character
var spectator:Character
var player:Character

var cpu_strums:StrumLine
var player_strums:StrumLine

var default_cam_zoom:float = 1.05
	
var accuracy:float:
	get:
		if accuracy_total_hit != 0.0 and accuracy_pressed_notes != 0.0:
			return accuracy_total_hit / accuracy_pressed_notes

		return 0.0
		
var note_skin:NoteSkin

@onready var camera:Camera2D = $Camera2D
@onready var hud:CanvasLayer = $HUD

@onready var strumlines:Node2D = $HUD/StrumLines

@onready var note_group:CanvasGroup = $HUD/Notes
@onready var combo_group:CanvasGroup = $Ratings

@onready var rating_template:VelocitySprite = $Ratings/RatingTemplate
@onready var combo_template:VelocitySprite = $Ratings/ComboTemplate

@onready var health_bar_bg:ColorRect = $HUD/HealthBar
@onready var health_bar:ProgressBar = $HUD/HealthBar/ProgressBar

@onready var cpu_icon:Sprite2D = $HUD/HealthBar/ProgressBar/CPUIcon
@onready var player_icon:Sprite2D = $HUD/HealthBar/ProgressBar/PlayerIcon
@onready var score_text:Label = $HUD/HealthBar/ScoreText

@onready var inst:AudioStreamPlayer = $Inst
@onready var voices:AudioStreamPlayer = $Voices

func _ready():
	super._ready()
	
	if Global.SONG == null:
		Global.SONG = Chart.load_chart("bopeebo", "hard")
		SONG = Global.SONG
		
	note_skin = Global.note_skins[SONG.note_skin]
		
	inst.stream = load("res://assets/songs/"+SONG.name.to_lower()+"/Inst.ogg")
	inst.pitch_scale = Conductor.rate
	inst.finished.connect(end_song)
	
	voices.stream = load("res://assets/songs/"+SONG.name.to_lower()+"/Voices.ogg")
	voices.pitch_scale = Conductor.rate
		
	Conductor.map_bpm_changes(SONG)
	Conductor.change_bpm(SONG.bpm)
	Conductor.position = Conductor.crochet * -5
		
	for section in SONG.sections:
		for note in section.notes:
			# i can't use fucking duplicate
			# it fucks up!!!
			var n = SectionNote.new()
			n.time = note.time
			n.direction = note.direction
			n.length = note.length
			n.type = note.type
			n.player_section = section.is_player
			note_data_array.append(n)
			
	note_data_array.sort_custom(func(a, b): return a.time < b.time)
	
	health = max_health * 0.5
	
	health_bar.min_value = 0.0
	health_bar.max_value = max_health
	health_bar.value = health
	
	update_score_text()
	
	cpu_strums = load("res://scenes/gameplay/strumlines/"+str(SONG.key_count)+"K.tscn").instantiate()
	cpu_strums.note_skin = note_skin
	strumlines.add_child(cpu_strums)
	
	player_strums = load("res://scenes/gameplay/strumlines/"+str(SONG.key_count)+"K.tscn").instantiate()
	player_strums.note_skin = note_skin
	strumlines.add_child(player_strums)
	
	var strum_y:float = Global.game_size.y - 100 if SettingsAPI.get_setting("downscroll") else 100
	cpu_strums.position = Vector2((Global.game_size.x * 0.5) - 320, strum_y)
	player_strums.position = Vector2((Global.game_size.x * 0.5) + 320, strum_y)
	
	var stage_path:String = "res://scenes/gameplay/stages/"+SONG.stage+".tscn"
	if ResourceLoader.exists(stage_path):
		stage = load(stage_path).instantiate()
	else:
		stage = load("res://scenes/gameplay/stages/stage.tscn").instantiate()
		
	default_cam_zoom = stage.default_cam_zoom
	camera.zoom = Vector2(default_cam_zoom, default_cam_zoom)
		
	add_child(stage)
	
	var spectator_path:String = "res://scenes/gameplay/characters/"+SONG.spectator+".tscn"
	if ResourceLoader.exists(spectator_path):
		spectator = load(spectator_path).instantiate()
	else:
		spectator = load("res://scenes/gameplay/characters/bf.tscn").instantiate()
		
	spectator.position = stage.character_positions["spectator"].position + spectator.position_offset
	add_child(spectator)
	
	var opponent_path:String = "res://scenes/gameplay/characters/"+SONG.opponent+".tscn"
	if ResourceLoader.exists(opponent_path):
		opponent = load(opponent_path).instantiate()
	else:
		opponent = load("res://scenes/gameplay/characters/bf.tscn").instantiate()
		
	opponent.position = stage.character_positions["opponent"].position + opponent.position_offset
	add_child(opponent)
	
	var player_path:String = "res://scenes/gameplay/characters/"+SONG.player+".tscn"
	if ResourceLoader.exists(player_path):
		player = load(player_path).instantiate()
	else:
		player = load("res://scenes/gameplay/characters/bf.tscn").instantiate()
		
	player._is_true_player = true
	player.position = stage.character_positions["player"].position + player.position_offset
	add_child(player)
	
	cpu_icon.texture = opponent.health_icon
	cpu_icon.hframes = opponent.health_icon_frames
	
	player_icon.texture = player.health_icon
	player_icon.hframes = player.health_icon_frames
	
	OPPONENT_HEALTH_COLOR.bg_color = opponent.health_color
	PLAYER_HEALTH_COLOR.bg_color = player.health_color
	
	if SettingsAPI.get_setting("downscroll"):
		health_bar_bg.position.y = 60
	
	combo_group.move_to_front()
	update_camera()
	
	for i in player_strums.get_child_count():
		pressed.append(false)
		
	SettingsAPI.setup_binds()
			
func start_song():
	starting_song = false
	Conductor.position = 0.0
	
	inst.play()
	voices.play()
	
func end_song():
	print("ending the jas dghj")
	ending_song = true
	
func _beat_hit(beat:int):
	cpu_icon.scale += Vector2(0.3, 0.3)
	player_icon.scale += Vector2(0.3, 0.3)
	position_icons()
	
	if beat % 4 == 0:
		camera.zoom += Vector2(0.015, 0.015)
		hud.scale += Vector2(0.03, 0.03)
		position_hud()
		
	if opponent != null and not opponent.last_anim.begins_with("sing"):
		opponent.dance()
		
	if spectator != null and not spectator.last_anim.begins_with("sing"):
		spectator.dance()
		
	if player != null and not player.last_anim.begins_with("sing"):
		player.dance()
		
	update_camera(Conductor.cur_section)
	
func update_camera(sec:int = 0):
	if not range(SONG.sections.size()).has(sec): return
	
	var cur_sec:Section = SONG.sections[sec]
	if cur_sec != null and cur_sec.is_player:
		camera.position = player.get_camera_pos()
	else:
		camera.position = opponent.get_camera_pos()
	
func position_hud():
	hud.offset.x = (hud.scale.x - 1.0) * -(Global.game_size.x * 0.5)
	hud.offset.y = (hud.scale.y - 1.0) * -(Global.game_size.y * 0.5)
	
func _step_hit(step:int):
	if not ending_song and (not Conductor.is_sound_synced(inst) or (not Conductor.is_sound_synced(voices) and voices.get_playback_position() < voices.stream.get_length())):
		resync_vocals()
		
func resync_vocals():
	if ending_song: return
	
	inst.stop()
	voices.stop()
	
	inst.play(Conductor.position / 1000.0)
	voices.play(Conductor.position / 1000.0)

func key_from_event(event:InputEventKey):
	var data:int = -1
	for i in player_strums.controls.size():
		if event.is_action_pressed(player_strums.controls[i]) or event.is_action_released(player_strums.controls[i]):
			data = i
			break
			
	return data
	
var pressed:Array[bool] = []
	
func _input(event):
	if event is InputEventKey:
		var key_event:InputEventKey = event
		var data:int = key_from_event(key_event)
		
		if data > -1:
			pressed[data] = event.is_pressed()
		
		if data == -1 or not Input.is_action_just_pressed(player_strums.controls[data]):
			return
		
		var receptor:Receptor = player_strums.get_child(data)
		receptor.play_anim("pressed")
		
		var possible_notes:Array[Note] = []
		for note in note_group.get_children().filter(func(note:Note):
			return (note.direction == data and !note.too_late and note.can_be_hit and note.must_press and not note.was_good_hit)	
		): possible_notes.append(note)
		
		possible_notes.sort_custom(sort_hit_notes)
		
		var dont_hit:Array[bool] = []
		for i in player_strums.get_child_count():
			dont_hit.append(false)
			
		if possible_notes.size() > 0:
			for note in possible_notes:
				if not dont_hit[data] and note.direction == data:
					dont_hit[data] = true
					
				receptor.play_anim("confirm")
				good_note_hit(note)
				
				# fuck you stacked notes
				# they can go kiss my juicy ass
				if possible_notes.size() > 1:
					for i in possible_notes.size():
						if i == 0: continue
						var bad_note:Note = possible_notes[i]
						if absf(bad_note.time - note.time) <= 5 and note.direction == data:
							bad_note.queue_free()
					
				break
		else:
			fake_miss(data)
			
func fake_miss(direction:int = -1):
	health -= 0.0475
	misses += 1
	score -= 10
	combo = 0
	accuracy_pressed_notes += 1
	voices.volume_db = -80
	update_score_text()
	
	if direction < 0: return
	
	var sing_anim:String = "sing"+player_strums.get_child(direction).direction.to_upper()
	player.play_anim(sing_anim+"miss", true)
	player.hold_timer = 0.0
		
func sort_hit_notes(a:Note, b:Note):
	if not a.should_hit and b.should_hit: return 1
	elif a.should_hit and not b.should_hit: return -1
	
	return a.time < b.time
	
func pop_up_score(judgement:Judgement):
	accuracy_pressed_notes += 1
	accuracy_total_hit += judgement.accuracy_gain
	score += judgement.score
	combo += 1
	
	var rating_spr:VelocitySprite = rating_template.duplicate()
	rating_spr.texture = load("res://assets/images/gameplay/score/default/"+judgement.name+".png")
	rating_spr.visible = true
	
	rating_spr.acceleration.y = 550
	rating_spr.velocity.y = -randi_range(140, 175)
	rating_spr.velocity.x = -randi_range(0, 10)
	
	var timer = get_tree().create_timer(Conductor.crochet * 0.001)
	timer.connect("timeout", func():
		var tween = get_tree().create_tween()
		tween.tween_property(rating_spr, "modulate:a", 0.0, 0.2)
		tween.tween_callback(rating_spr.queue_free)
	)
	combo_group.add_child(rating_spr)
	
	var separated_score:String = Global.add_zeros(str(combo), 3)
	for i in len(separated_score):
		var num_score:VelocitySprite = combo_template.duplicate()
		num_score.texture = load("res://assets/images/gameplay/score/default/num"+separated_score.substr(i, 1)+".png")
		num_score.position = Vector2((43 * i) - 90, 80)
		num_score.visible = true
		
		num_score.acceleration.y = randi_range(200, 300)
		num_score.velocity.y = -randi_range(140, 160)
		num_score.velocity.x = randi_range(-5, 5)
		
		var timer2 = get_tree().create_timer(Conductor.crochet * 0.002)
		timer2.connect("timeout", func():
			var tween = get_tree().create_tween()
			tween.tween_property(num_score, "modulate:a", 0.0, 0.2)
			tween.tween_callback(num_score.queue_free)
		)
		combo_group.add_child(num_score)
		
func good_note_hit(note:Note):
	if note.was_good_hit: return
	
	voices.volume_db = 0
	
	var note_diff:float = (note.time - Conductor.position) / Conductor.rate
	var judgement:Judgement = Ranking.judgement_from_time(note_diff)
	
	if judgement.do_splash:
		var receptor:Receptor = player_strums.get_child(note.direction)
		receptor.splash.frame = 0
		var anim:String = "note impact "+str(randi_range(1, 2))+" "+Global.note_directions[note.direction]
		receptor.splash.play(anim)
		receptor.splash.visible = true
		receptor.splash.speed_scale = randf_range(0.5, 1.2)
	
	pop_up_score(judgement)	
	update_score_text()
	
	note.was_good_hit = true
	if note.length <= 0:
		note.queue_free()
	else:
		note.anim_sprite.visible = false
		note.length += note_diff
	
	var sing_anim:String = "sing"+player_strums.get_child(note.direction).direction.to_upper()
	player.play_anim(sing_anim, true)
	player.hold_timer = 0.0
	
	health += 0.023

func position_icons():
	var icon_offset:int = 26
	var percent:float = (health_bar.value / health_bar.max_value) * 100
	
	var cpu_icon_width:float = (cpu_icon.texture.get_width() / cpu_icon.hframes) * cpu_icon.scale.x

	player_icon.position.x = (health_bar.size.x * ((100 - percent) * 0.01)) - icon_offset
	cpu_icon.position.x = (health_bar.size.x * ((100 - percent) * 0.01)) - (cpu_icon_width - icon_offset)

func update_score_text():
	score_text.text = "Score: "+str(score)+" - Misses: "+str(misses)+" - Accuracy: "+str(snapped(accuracy * 100.0, 0.01))+"% ["+Ranking.rank_from_accuracy(accuracy * 100.0).name+"]"

func _process(delta):
	if not pressed.has(true) and player.last_anim.begins_with("sing") and player.hold_timer >= Conductor.step_crochet * player.sing_duration * 0.0011:
		player.hold_timer = 0.0
		player.dance()
			
	var percent:float = (health / max_health) * 100.0
	health_bar.max_value = max_health
	health_bar.value = health
	
	cpu_icon.health = 100.0 - percent
	player_icon.health = percent
	
	var icon_speed:float = clampf((delta * 60 * 0.15) * Conductor.rate, 0.0, 1.0)
	cpu_icon.scale = lerp(cpu_icon.scale, Vector2.ONE, icon_speed)
	player_icon.scale = lerp(player_icon.scale, Vector2.ONE, icon_speed)
	position_icons()
	
	var camera_speed:float = clampf((delta * 60 * 0.05) * Conductor.rate, 0.0, 1.0)
	camera.zoom = lerp(camera.zoom, Vector2(default_cam_zoom, default_cam_zoom), camera_speed)
	hud.scale = lerp(hud.scale, Vector2.ONE, camera_speed)
	position_hud()
	
	if not ending_song:
		Conductor.position += (delta * 1000.0) * Conductor.rate
		if Conductor.position >= 0.0 and starting_song:
			start_song()
	
	for note in note_data_array:
		if note.time > Conductor.position + (2500 / (scroll_speed / Conductor.rate)): break
		
		var key_count:int = 4
		var is_player_note:bool = note.player_section
		
		if note.direction > key_count - 1:
			is_player_note = !note.player_section
			
		var new_note:Note = template_notes[note.type].duplicate()
		new_note.position = Vector2(-9999, -9999)
		new_note.time = note.time
		new_note.direction = note.direction % key_count
		new_note.length = note.length * 0.85
		new_note.strumline = player_strums if is_player_note else cpu_strums
		new_note.must_press = is_player_note
		new_note.note_skin = note_skin
		note_group.add_child(new_note)
		
		note_data_array.erase(note)
