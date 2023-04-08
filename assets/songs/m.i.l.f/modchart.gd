extends FunkinScript
func on_beat_hit(curBeat:int):
	if curBeat >= 168 and curBeat < 200 and game.camera.zoom < Vector2(1.35,1.35):
		game.camera.zoom += Vector2(0.015,0.015)
		game.hud.scale += Vector2(0.03,0.03)
		game.position_hud()
