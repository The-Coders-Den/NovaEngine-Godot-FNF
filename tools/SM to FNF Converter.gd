extends Node2D

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
	"notes": []   }

func export_json(json_data):
	var json_str = JSON.stringify(json_data, 	)
	var file = FileAccess.open("res://testing.json", FileAccess.WRITE)
	file.store_string(json_str)

func _on_button_pressed():
	export_json(new_chart)
