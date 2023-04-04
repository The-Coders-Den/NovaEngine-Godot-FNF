extends Resource
class_name Section

var bpm:float = 0.0
var change_bpm:bool = false

var is_player:bool = false
var notes:Array[SectionNote] = []

var length_in_steps:int = 16
