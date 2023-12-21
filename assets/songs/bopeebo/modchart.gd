extends Modchart
func on_beat_hit(curbeat:int):
	if curbeat % 8 == 7: 
		game.player.play_anim("hey",true)
		game.player.special_anim = true
		game.player.hold_timer = 0.6
