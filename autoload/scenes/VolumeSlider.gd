extends CanvasLayer

var volume_tween:Tween

@onready var volume_panel:Panel = $VolumePanel
@onready var volume_icon:AnimatedSprite2D = $VolumePanel/VolumeIcon
@onready var progress_bar:ProgressBar = $VolumePanel/ProgressBar
@onready var beep_sound:AudioStreamPlayer = $BeepSound

func _ready():
	volume_panel.modulate.a = 0.0
	update_volume()

func _input(event):
	var timer = get_tree().create_timer(1.0,false)
	if event is InputEventKey and event.is_pressed():
		var key_event:InputEventKey = event
		
		if event.is_action_pressed("volume_down"):
			change_by(-0.1)
			
		if event.is_action_pressed("volume_up"):
			change_by(0.1)
			
		if event.is_action_pressed("volume_mute"):
			toggle_mute()
				
func toggle_mute():
	SettingsAPI.set_setting("muted", not SettingsAPI.get_setting("muted"))
	SettingsAPI.flush()
	show_panel()
	update_volume()

func change_by(amount:float):
	SettingsAPI.set_setting("volume", clampf(SettingsAPI.get_setting("volume") + amount, 0.0, 1.0))
	SettingsAPI.flush()
	show_panel()
	update_volume()
	
func show_panel():
	if volume_tween != null:
		volume_tween.stop()
		
	volume_panel.modulate.a = 1.0
	progress_bar.value = SettingsAPI.get_setting("volume") if not SettingsAPI.get_setting("muted") else 0.0
	
	if progress_bar.value <= 0:
		volume_icon.play("mute")
	elif progress_bar.value <= 0.5:
		volume_icon.play("mid")
	else:
		volume_icon.play("full")
		
	volume_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	volume_tween.tween_property(volume_panel, "modulate:a", 0.0, 0.3).set_delay(0.5)
	
	beep_sound.pitch_scale = remap(progress_bar.value, 0, 1, 0.2, 1) if SettingsAPI.get_setting("volume beep pitching") else 1.0
	beep_sound.play(0.0)
	
func update_volume():
	AudioServer.set_bus_volume_db(0, linear_to_db(SettingsAPI.get_setting("volume")))
	AudioServer.set_bus_mute(0, SettingsAPI.get_setting("muted"))
