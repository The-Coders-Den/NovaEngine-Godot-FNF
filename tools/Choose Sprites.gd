extends Button

@onready var file_dialog: FileDialog = $"../../FileDialog"

func popup_shit():
	file_dialog.popup_centered()
	file_dialog.size = Vector2(500, 500)
	file_dialog.position = Vector2(640 - 250, 360 - 250)
