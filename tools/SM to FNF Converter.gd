extends Node2D

var input_path = ""

var export_path = "res://assets/songs/"

var chart = ""

#variable jumpscare!!1!!!!
var song = "test"
var scroll_speed = 1.3
var player1 = "bf"
var player2 = "dad"
var spectator = "gf"
var bpm = 100 #ass\
var needvoices = false
var stage = "stage"
var snap = 16

var templatesection = {
	"lengthInSteps": snap,
	"mustHitSection": true, #we change this later lol :3
	"sectionNotes": []
}

# info:
# 16 snap is 150 ms

var new_chart = {
	"song": song,
	"bpm": bpm,
	"needsVoices": needvoices,
	"player1": player1,
	"player2": player2,
	"gf": spectator,
	"stage": stage,
	"speed": scroll_speed,
	"events": [],
	"notes": []   
	}
func export_json(json_data):
	player1 = $Panel/player1.text
	player2 = $Panel/player2.text
	print(player1)
	var json_str = JSON.stringify(json_data, 	)
	var file = FileAccess.open("res://testing.json", FileAccess.WRITE)
	file.store_string(json_str)

func sm_parser(file):
	print(file)
	print(input_path)

func _on_button_pressed():
	$"Save Chart".popup()

func _on_select_chart_pressed():
	$"Select File".popup()

func _on_select_file_file_selected(path):
	input_path = path
	$Panel2/Label.text = "current chart: " + input_path
	sm_parser(path)


func _on_save_chart_confirmed():
	export_json(new_chart)
