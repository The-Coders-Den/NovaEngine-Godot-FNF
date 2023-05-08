extends Cutscene

#jesus christ i had to implement the whole zooming thing the way "Gameplay.hud" does it

@onready var sound = $spoopy
var pb:ParallaxBackground

func _ready():
	pb = game.stage.get_node("PB")
	
	game.visible = false;
	game.hud.visible = false;
	pb.visible = false
	game.camera.zoom = Vector2(1.5, 1.5)
	game.camera.offset = Vector2(0, -2050)
	game.hud.scale = Vector2(2.1, 2.1)
	
	await get_tree().create_timer(randf_range(0.5, 1.5)).timeout
	
	game.visible = true
	game.hud.visible = true
	pb.visible = true
	sound.play()
	var tween = create_tween().set_parallel()
	tween.tween_property(game.camera, "zoom", Vector2(0.95, 0.95), 2.5)
	tween.tween_property(game.camera, "offset", Vector2(0, 0), 2.5)
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.finished.connect(finish)
	
func _process(delta):
	pb.offset.x = (game.camera.zoom.x - 1.0) * -(Global.game_size.x * 0.5)
	pb.offset.y = (game.camera.zoom.y - 1.0) * -(Global.game_size.y * 0.5)
	
func finish():
	var tween = create_tween()
	tween.tween_property(game.hud, "scale", Vector2(1, 1), Conductor.crochet / 1000)
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	_end()
