extends Node
class_name FunkinScript

var game:Gameplay

static func create(path:String, instance:Gameplay):
	var script:FunkinScript = load(path).instantiate()
	script.game = instance
	return script
	
func _ready_post():
	pass
	
func _process_post(delta:float):
	pass

func on_beat_hit(beat:int):
	pass
	
func on_step_hit(step:int):
	pass
	
func on_section_hit(section:int):
	pass
	
func on_beat_hit_post(beat:int):
	pass
	
func on_step_hit_post(step:int):
	pass
	
func on_section_hit_post(section:int):
	pass
	
# note functions
func on_note_spawn(note:Note):
	pass
	
func on_note_hit(note:Note):
	pass
	
func on_note_miss(note:Note):
	pass
	
func on_cpu_hit(note:Note):
	pass
	
func on_cpu_miss(note:Note):
	pass
	
func on_player_hit(note:Note):
	pass

func on_player_miss(note:Note):
	pass
	
# general gameplay functions
func on_update_score_text():
	pass
	
func on_position_icons():
	pass

func on_spawn_note_splash(splash:AnimatedSprite2D):
	pass
	
func on_show_ms():
	pass
	
func on_pop_up_score(combo:int):
	pass

func on_ghost_tap(direction:int):
	pass
	
func on_resync_vocals():
	pass
	
func on_update_camera():
	pass
	
func on_character_bop():
	pass
	
func on_start_song():
	pass
	
func on_end_song():
	pass
	
func on_start_countdown():
	pass
	
func on_countdown_tick(tick:int, tween:Tween):
	pass
	
func on_event(name:String, parameters:Array):
	pass
	
func on_destroy():
	pass

func on_exit_tree():
	pass
