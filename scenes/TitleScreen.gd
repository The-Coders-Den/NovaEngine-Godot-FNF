extends MusicBeatScene

var cur_wacky:PackedStringArray = ["yoooo swag shit", "ball shit"]
var flashing:bool = false

var skipped_intro:bool = false
var transitioning:bool = false

@onready var gf:AnimationPlayer = $TitleGroup/gf/AnimationPlayer
@onready var logo:AnimatedSprite = $TitleGroup/logo
@onready var title_enter:AnimatedSprite = $TitleGroup/titleEnter
@onready var title_group:Node2D = $TitleGroup

# yes we do just steal this from the scene but fuck you :3
@onready var color_swap:ShaderMaterial = logo.material

@onready var text_template:Alphabet = $TextTemplate
@onready var text_group:Node2D = $TextGroup
@onready var ng_spr:Sprite2D = $NgSpr

@onready var flash:ColorRect = $Flash

func _ready() -> void:
	super._ready()
	Audio.play_music("freakyMenu")
	Conductor.change_bpm(Audio.music.stream.bpm)
	
	gf.play("danceLeft")
	logo.play("logo bumpin")
	title_enter.play("Press Enter to Begin")
	cur_wacky = _get_wacky()

func _process(delta):
	Conductor.position = Audio.music.time
	
	if Input.is_action_just_pressed("switch_mod"):
		add_child(load("res://scenes/ModsMenu.tscn").instantiate())
	
	if Input.is_action_just_pressed("ui_accept"):
		if not skipped_intro:
			skip_intro()
		elif not transitioning:
			do_flash(1.0)
			transitioning = true
			title_enter.play("ENTER PRESSED")
			
			Audio.play_sound("menus/confirmMenu")
			
			var timer:SceneTreeTimer = get_tree().create_timer(2.0)
			timer.timeout.connect(func():
				SettingsAPI.update_settings()
				Global.switch_scene("res://scenes/MainMenu.tscn")
			)
	
	var axis:int = int(Input.get_axis('ui_left', 'ui_right'))
	
	if axis:
		color_swap.set_shader_parameter('time', color_swap.get_shader_parameter('time') + \
				(delta * 0.1) * axis)

func beat_hit(beat:int):
	logo.frame = 0
	logo.play("logo bumpin")
	
	gf.play("danceLeft" if beat % 2 == 0 else "danceRight")
	
	if skipped_intro: return
	
	match beat:
		1:
			create_cool_text(['swordcube', 'voiddev', 'leather128'])
		3:
			add_more_text('present')
		4:
			delete_cool_text()
		5:
			create_cool_text(['You should', 'check out'])
		7:
			add_more_text('newgrounds')
			ng_spr.visible = true
		8:
			delete_cool_text()
			ng_spr.visible = false
		9:
			create_cool_text([cur_wacky[0]])
		11:
			add_more_text(cur_wacky[1])
		12:
			delete_cool_text()
		13:
			add_more_text('Friday')
		14:
			add_more_text('Night')
		15:
			add_more_text('Funkin')
		_:
			if beat >= 16:
				skip_intro()
		
func skip_intro():
	skipped_intro = true
	
	delete_cool_text()
	title_group.visible = true
	ng_spr.visible = false
	
	do_flash()
	
func do_flash(duration:float = 4.0):
	if flashing: return
	
	flashing = true
	flash.modulate.a = 1.0
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, duration)
	tween.finished.connect(func(): flashing = false)
	
func create_cool_text(text_array:PackedStringArray):
	for i in len(text_array):
		add_more_text(text_array[i])
		
func add_more_text(text:String):
	var money:Alphabet = text_template.duplicate()
	money.text = text
	money.screen_center("X")
	money.position.y += (text_group.get_child_count() * 60)
	money.visible = true
	text_group.add_child(money)
	
func delete_cool_text():
	while text_group.get_child_count() > 0:
		var piss:Alphabet = text_group.get_child(0)
		piss.queue_free()
		text_group.remove_child(piss)

func _get_wacky() -> PackedStringArray:
	var wackies_file:FileAccess = FileAccess.open("res://assets/introTexts.txt", FileAccess.READ)
	var wacky_text:String = wackies_file.get_as_text()
	var wacky_lines:PackedStringArray = wacky_text.split("\n", false)
	
	return wacky_lines[randi_range(0, wacky_lines.size()-1)].split("--")
