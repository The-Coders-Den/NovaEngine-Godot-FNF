@tool
@icon("res://editor/icons/alphabet.png")

extends Alphabet
class_name FreeplayAlphabet

func _process(delta):
	super._process(delta)
	if not "__TemplateSong__" in name and not Engine.is_editor_hint():
		visible = not (position.y < -(size.y + 20) or position.y > Global.game_size.y + 20)
