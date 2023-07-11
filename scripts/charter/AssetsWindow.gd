extends Window

@onready var chart_data:
	get:
		return get_parent().chart_data

@onready var char_dialog:FileDialog = $"../CharDialog"
@onready var stage_dialog:FileDialog = $"../StageDialog"
@onready var ui_skin_dialog:FileDialog = $"../UISkinDialog"
@onready var switch_buttons = [
	$Panel/ScrollContainer/VBoxContainer/Player/SwitchButton,
	$Panel/ScrollContainer/VBoxContainer/Opponent/SwitchButton,
	$Panel/ScrollContainer/VBoxContainer/Spectator/SwitchButton,
	$Panel/ScrollContainer/VBoxContainer/Stage/SwitchButton,
	$Panel/ScrollContainer/VBoxContainer/UISKin/SwitchButton,
	$"../song/Panel/ScrollContainer/VBoxContainer/SaveSong",
	$"../song/Panel/ScrollContainer/VBoxContainer/ReloadAudio",
	$"../song/Panel/ScrollContainer/VBoxContainer/LoadJSON"
]
var cur_button:String = "bf" # For Char Switching.

func enable_switches():
	for button in switch_buttons:
		button.disabled = false

func disable_switches():
	for button in switch_buttons:
		button.disabled = true

func select_char(path:String):
	match cur_button:
		"bf":
			chart_data.player = path.get_file().get_basename()
			$Panel/ScrollContainer/VBoxContainer/Player.text = "Player: " + chart_data.player
		"gf":
			chart_data.spectator = path.get_file().get_basename()
			$Panel/ScrollContainer/VBoxContainer/Spectator.text = "Spectator: " + chart_data.spectator
		"dad":
			chart_data.opponent = path.get_file().get_basename()
			$Panel/ScrollContainer/VBoxContainer/Opponent.text = "Opponent: " + chart_data.opponent
	enable_switches()

func select_stage(path:String):
	chart_data.stage = path.get_file().get_basename()
	$Panel/ScrollContainer/VBoxContainer/Stage.text = "Stage: " + chart_data.stage
	enable_switches()
	
func select_ui_skin(path:String):
	chart_data.ui_skin = path.get_file().get_basename()
	$Panel/ScrollContainer/VBoxContainer/UISKin.text = "UI Skin: " + chart_data.ui_skin
	enable_switches()

func _switch_player():
	cur_button = "bf"
	char_dialog.popup_centered()
	disable_switches()
	
func _switch_spectator():
	cur_button = "gf"
	char_dialog.popup_centered()
	disable_switches()
	
func _switch_opponent():
	cur_button = "dad"
	char_dialog.popup_centered()
	disable_switches()

func _switch_stage():
	stage_dialog.popup_centered()
	disable_switches()
	
func _switch_ui_skin():
	ui_skin_dialog.popup_centered()
	disable_switches()
