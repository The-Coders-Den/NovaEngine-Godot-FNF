extends Cutscene

@onready var sound = $shootIForgotTheElectricityBill #dont ask.

func _ready():
	game.visible = false
	game.stage.get_node("PB").queue_free()
	game.hud.visible = false
	sound.finished.connect(_end)
