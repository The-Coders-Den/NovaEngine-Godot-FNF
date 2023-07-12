extends ColorRect

@onready var icon := $Icon
@onready var progress_bar := $ProgressBar
@onready var fade_timer := $FadeTimer

var cur_volume:float = 0.5
var muted:bool = false
var fade_tween:Tween

func _ready():
	modulate.a = 0.0
	fade_timer.timeout.connect(fade_out)
	
	set_volume(Options.volume)
	muted = Options.muted
	AudioServer.set_bus_mute(0, muted)

func _input(event:InputEvent):
	if not event is InputEventKey: return
	event = event as InputEventKey
	
	if Input.is_action_just_pressed("volume_mute"):
		toggle_mute(not muted)
		
	adjust_volume(Input.get_axis("volume_down", "volume_up") * 0.1)
	
func toggle_mute(new_value:bool):
	muted = new_value
	Options.muted = new_value
	AudioServer.set_bus_mute(0, new_value)
	
	show_slider()
	SFXHelper.play(SFXHelper.VOLUME_DOWN if muted else SFXHelper.VOLUME_UP)
		
func set_volume(volume:float):
	cur_volume = clampf(volume, 0.0, 1.0)
	Options.volume = cur_volume
	AudioServer.set_bus_volume_db(0, linear_to_db(cur_volume))
	
func adjust_volume(amount:float):
	if amount == 0.0: return
	
	set_volume(cur_volume + amount)
	progress_bar.value = cur_volume
	toggle_mute(false)
	show_slider()
	
	SFXHelper.play(SFXHelper.VOLUME_DOWN if amount < 0 else SFXHelper.VOLUME_UP)
	
func show_slider():
	modulate.a = 1.0
	
	fade_timer.stop()
	if is_instance_valid(fade_tween): fade_tween.stop()
	
	fade_timer.start(0.5)
	update_icon()
	
func update_icon():
	if cur_volume <= 0.05 or muted:
		icon.play("mute")
	elif cur_volume <= 0.5:
		icon.play("mid")
	else:
		icon.play("full")
	
func fade_out():
	fade_tween = get_tree().create_tween()
	fade_tween.set_ease(Tween.EASE_IN)
	fade_tween.set_trans(Tween.TRANS_CUBIC)
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	fade_tween.tween_callback(Options.flush)
