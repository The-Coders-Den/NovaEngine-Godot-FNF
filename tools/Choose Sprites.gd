extends Button

@onready var file_dialog: FileDialog = $"../../file_dialog"

func popup_shit() -> void:
	file_dialog.size = Vector2(500, 500)
	file_dialog.popup_centered()
