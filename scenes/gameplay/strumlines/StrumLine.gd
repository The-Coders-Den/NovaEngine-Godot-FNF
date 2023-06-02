class_name StrumLine extends Node2D

@export var type:Tools.StrumLineType = Tools.StrumLineType.OPPONENT

func _ready():
	for i in get_child_count():
		if type != Tools.StrumLineType.PLAYER:
			var receptor:Receptor = get_child(i)
			receptor.sprite.animation_finished.connect(func(): play_anim(i, Tools.ReceptorAnim.STATIC))
		play_anim(i, Tools.ReceptorAnim.STATIC)
	
func play_anim(dir:Tools.NoteDirection, anim:Tools.ReceptorAnim):
	var receptor:Receptor = get_child(dir)
	match anim:
		Tools.ReceptorAnim.PRESS, Tools.ReceptorAnim.PRESSED:
			receptor.play_anim(Tools.dir_to_str(dir)+" press")
		Tools.ReceptorAnim.HIT, Tools.ReceptorAnim.CONFIRM:
			receptor.play_anim(Tools.dir_to_str(dir)+" confirm")
		_:
			receptor.play_anim(Tools.dir_to_str(dir)+" static")
