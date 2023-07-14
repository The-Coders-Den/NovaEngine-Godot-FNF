extends Node2D

@onready var buttons := $CanvasLayer/Buttons
@onready var watermark := $CanvasLayer/Watermark
@onready var magenta_flicker := $ParallaxNode/Magenta/FlickerAnimation

@onready var camera := $Camera2D

@onready var scroll_audio := $MenuSounds/Scroll
@onready var confirm_audio := $MenuSounds/Confirm
@onready var cancel_audio := $MenuSounds/Cancel

var cur_item:int = 0
var exiting:bool = false

func _ready():
	for i in buttons.get_child_count():
		var button = buttons.get_child(i)
		
		if not (button is AnimatedSprite2D):
			button.queue_free()
			printerr("Only AnimatedSprite2D objects can be used as menu buttons.")
			continue
			
		button.play("idle" if i != 0 else "selected")
	
	watermark.text = "Nova Engine Godot - %s [%s]" % [str(Global.VERSION), Global.VERSION.type_to_string()]

func _unhandled_key_input(event):
	event = event as InputEventKey
	if not event.is_pressed() or exiting: return
	
	var scroll_axis:int = Input.get_axis("ui_up","ui_down")
	
	if scroll_axis != 0:
		change_item(scroll_axis)
		
	if Input.is_action_just_pressed("ui_accept"):
		select_item()
		
func change_item(inc:int):
	cur_item = wrapi(cur_item + inc, 0, buttons.get_child_count())
	
	scroll_audio.play()
	
	for i in buttons.get_child_count():
		buttons.get_child(i).play("idle" if i != cur_item else "selected")
		
	camera.position = buttons.get_child(cur_item).position + buttons.position
	
func select_item():
	var button_name = buttons.get_child(cur_item).name
	match (button_name):
		# Type in "${NAME_OF_BUTTON}:" to add special cases for certain buttons.
		_:
			var scene_name = "res://scenes/menus/" + button_name + "Menu.tscn"
			
			if not ResourceLoader.exists(scene_name):
				printerr("Scene \"" + scene_name + "\" doesn't exist! Cancelling the select function.")
				cancel_audio.play()
				return
			
			magenta_flicker.play("flicker")
			confirm_audio.play()
			exiting = true
			
			var flicker:AnimationPlayer = buttons.get_child(cur_item).get_node("FlickerAnimation")
			flicker.play("flicker")
			flicker.animation_finished.connect(func(anim): Global.switch_scene(scene_name))
