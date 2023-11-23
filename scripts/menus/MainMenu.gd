extends Node2D

@onready var buttons := $CanvasLayer/Buttons
@onready var watermark := $CanvasLayer/Watermark
@onready var magenta_flicker := $ParallaxNode/Magenta/FlickerAnimation

@onready var camera := $Camera2D

var cur_item:int = 0
var exiting:bool = false

func _ready():
	Audio.play_music("freakyMenu")
	for i in buttons.get_child_count():
		var button = buttons.get_child(i)
		
		if not (button is AnimatedSprite2D):
			button.queue_free()
			printerr("Only AnimatedSprite2D objects can be used as menu buttons.")
			continue
			
		button.play("idle" if i != 0 else "selected")
	
	watermark.text = "Nova Engine Godot - %s [%s]" % [str(Global.VERSION), Global.VERSION.type_to_string()]
	change_item()

func _unhandled_key_input(event):
	event = event as InputEventKey
	if not event.is_pressed() or exiting: return
	
	var scroll_axis = -int(event.is_action_pressed("ui_up")) + int(event.is_action_pressed("ui_down"))
	
	if scroll_axis != 0:
		change_item(scroll_axis)
		
	if event.is_action_pressed("ui_accept"):
		select_item()
		
func change_item(inc:int = 0):
	cur_item = wrapi(cur_item + inc, 0, buttons.get_child_count())
	
	Audio.play_sound(Audio.MENU_SOUNDS.SCROLL)
	
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
				Audio.play_sound(Audio.MENU_SOUNDS.CANCEL)
				return
			
			magenta_flicker.play("flicker")
			Audio.play_sound(Audio.MENU_SOUNDS.CONFIRM)
			exiting = true
			
			for i in buttons.get_child_count():
				if i == cur_item: continue
				var tween := create_tween()
				tween.tween_property(buttons.get_child(i), "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			
			var flicker:AnimationPlayer = buttons.get_child(cur_item).get_node("FlickerAnimation")
			flicker.play("flicker")
			flicker.animation_finished.connect(func(_anim):
				await get_tree().create_timer(0.1).timeout
				Global.switch_scene(scene_name)
			)
