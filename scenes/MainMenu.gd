extends MusicBeatScene

@onready var magenta_anim:AnimationPlayer = $PB/BGLayer/Magenta/AnimationPlayer
@onready var button_anim:AnimationPlayer = $PB/UILayer/ButtonFlashing

@onready var camera:Camera2D = $Camera2D
@onready var buttons:Node2D = $PB/UILayer/Buttons

var cur_selected:int = 0
var selected_something:bool = false

func _ready():
	super._ready()
	get_tree().paused = false
	Audio.play_music("freakyMenu")
	Conductor.change_bpm(Audio.music.stream.bpm)
	
	change_selection()
	
func _process(delta):
	if selected_something: return
	
	if Input.is_action_just_pressed("ui_cancel"):
		Audio.play_sound("cancelMenu")
		Global.switch_scene("res://scenes/TitleScreen.tscn")
		
	if Input.is_action_just_pressed("switch_mod"):
		add_child(load("res://scenes/ModsMenu.tscn").instantiate())
	
	if Input.is_action_just_pressed("ui_up"):
		change_selection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		change_selection(1)
		
	if Input.is_action_just_pressed("ui_accept"):
		Audio.play_sound("confirmMenu")
		selected_something = true
		magenta_anim.play("flash")
		
		button_anim.root_node = buttons.get_child(cur_selected).get_path()
		button_anim.play("flash")
		
		button_anim.animation_finished.connect(func(anim_name:StringName):
			for i in buttons.get_child_count():
				var button:AnimatedSprite2D = buttons.get_child(i)
				
				var tween = get_tree().create_tween()
				tween.set_ease(Tween.EASE_OUT)
				tween.set_trans(Tween.TRANS_QUAD)
				tween.tween_property(button, "modulate:a", 0.0, 0.4)
				
			var timer:SceneTreeTimer = get_tree().create_timer(0.45)
			timer.timeout.connect(func():
				var button:StringName = buttons.get_child(cur_selected).name
				match str(button):
					"StoryMode":
						Global.switch_scene("res://scenes/StoryMenu.tscn")
					
					"Freeplay":
						Global.switch_scene("res://scenes/FreeplayMenu.tscn")
						
					"Options":
						Global.switch_scene("res://scenes/OptionsMenu.tscn")
						
					_: print("bro how the fuck did you select "+button+"???")
			)
		)
		
func _input(e):
	if not e is InputEventMouseButton: return
	var event:InputEventMouseButton = e
	if not event.pressed: return
	
	match event.button_index:
		MOUSE_BUTTON_WHEEL_UP:
			change_selection(-1)
			
		MOUSE_BUTTON_WHEEL_DOWN:
			change_selection(1)
	
func change_selection(change:int = 0):
	cur_selected = wrapi(cur_selected + change, 0, buttons.get_child_count())
	
	for i in buttons.get_child_count():
		var button:AnimatedSprite2D = buttons.get_child(i)
		button.play("selected" if cur_selected == i else "idle")
		
	Audio.play_sound("scrollMenu")
	camera.position.y = buttons.get_child(cur_selected).position.y
