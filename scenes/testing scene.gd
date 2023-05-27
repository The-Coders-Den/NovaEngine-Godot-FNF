extends Node2D

func _input(event):
	if event is InputEventJoypadButton:
		var joypad_event = event as InputEventJoypadButton
		var joypad_index = joypad_event.device
		var button_index = joypad_event.button_index
		
		if joypad_event.pressed:
			print("Joypad", joypad_index, "button", button_index, "pressed")
		else:
			print("Joypad", joypad_index, "button", button_index, "released")


