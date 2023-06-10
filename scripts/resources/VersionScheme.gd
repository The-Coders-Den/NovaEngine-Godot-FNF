class_name VersionScheme extends Resource

var major:int 
var minor:int
var patch:int
var type:Global.VersionType

func _init(major:int = 0, minor:int = 0, patch:int = 1, type:Global.VersionType = Global.VersionType.DEV):
	self.major = major
	self.minor = minor
	self.patch = patch
	self.type = type

# allows you to do str(Global.VERSION)
func _to_string() -> String:
	return "v%s.%s.%s" % [str(major), str(minor), str(patch)]

func type_to_string() -> String:
	return Global.VersionType.keys()[type].replace("_", "-")
