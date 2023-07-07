extends Node

signal on_scene_switch(node:Node)

signal on_note_hit(event:NoteHitEvent)
signal on_note_miss(event:NoteMissEvent)

signal on_resync_tracks()

#-- DON'T WORRY ABOUT THESE --#
var scene_path:String

func _enter_tree():
	get_tree().node_added.connect(_on_node_added)
	
func _on_node_added(node:Node):
	if node.get_parent() == get_tree().root:
		var path:String = node.scene_file_path
		if path and scene_path != path:
			scene_path = path
			on_scene_switch.emit(node)
