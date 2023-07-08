class_name Global extends Node

static var VERSION:VersionScheme = VersionScheme.new(2, 0, 0, VersionScheme.VersionType.DEV)

static func switch_scene(path:String):
	Options.get_tree().change_scene_to_file(path)
