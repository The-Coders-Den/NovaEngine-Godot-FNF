extends Window

@onready var chart_data:Chart:
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
	$Panel/ScrollContainer/VBoxContainer/UISkin/SwitchButton,
	$"../song/Panel/ScrollContainer/VBoxContainer/SaveSong",
	$"../song/Panel/ScrollContainer/VBoxContainer/ReloadAudio",
	$"../song/Panel/ScrollContainer/VBoxContainer/LoadJSON"
]
var cur_button:String = "bf" # For Char Switching.

@onready var plr_label = $Panel/ScrollContainer/VBoxContainer/Player
@onready var cpu_label = $Panel/ScrollContainer/VBoxContainer/Opponent
@onready var spec_label = $Panel/ScrollContainer/VBoxContainer/Spectator
@onready var stage_label = $Panel/ScrollContainer/VBoxContainer/Stage
@onready var ui_label = $Panel/ScrollContainer/VBoxContainer/UISkin

func _ready():
	plr_label.text = "Player: " + chart_data.player
	spec_label.text = "Spectator: " + chart_data.spectator
	cpu_label.text = "Opponent: " + chart_data.opponent
	stage_label.text = "Stage: " + chart_data.stage
	ui_label.text = "UI Skin: " + chart_data.ui_skin

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
			plr_label.text = "Player: " + chart_data.player
		"gf":
			chart_data.spectator = path.get_file().get_basename()
			spec_label.text = "Spectator: " + chart_data.spectator
		"dad":
			chart_data.opponent = path.get_file().get_basename()
			cpu_label.text = "Opponent: " + chart_data.opponent
	enable_switches()

func select_stage(path:String):
	chart_data.stage = path.get_file().get_basename()
	stage_label.text = "Stage: " + chart_data.stage
	enable_switches()
	
func select_ui_skin(path:String):
	chart_data.ui_skin = path.get_file().get_basename()
	ui_label.text = "UI Skin: " + chart_data.ui_skin
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
