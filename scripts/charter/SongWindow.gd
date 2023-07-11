extends Window

@onready var switch_buttons = [
	$"../assets/Panel/ScrollContainer/VBoxContainer/Player/SwitchButton",
	$"../assets/Panel/ScrollContainer/VBoxContainer/Opponent/SwitchButton",
	$"../assets/Panel/ScrollContainer/VBoxContainer/Spectator/SwitchButton",
	$"../assets/Panel/ScrollContainer/VBoxContainer/Stage/SwitchButton",
	$"../assets/Panel/ScrollContainer/VBoxContainer/UISKin/SwitchButton",
	$"Panel/ScrollContainer/VBoxContainer/SaveSong",
	$"Panel/ScrollContainer/VBoxContainer/ReloadAudio",
	$"Panel/ScrollContainer/VBoxContainer/LoadJSON"
]

func enable_switches():
	for button in switch_buttons:
		button.disabled = false

func disable_switches():
	for button in switch_buttons:
		button.disabled = true
