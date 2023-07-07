class_name VersionScheme extends Resource

enum VersionType {
	DEV,
	BETA,
	PRE_RELEASE,
	RELEASE
}

var major:int 
var minor:int
var patch:int
var type:VersionType

func _init(major:int = 0, minor:int = 0, patch:int = 1, type:VersionType = VersionType.DEV):
	self.major = major
	self.minor = minor
	self.patch = patch
	self.type = type

# allows you to do str(Global.VERSION)
func _to_string() -> String:
	return "v%s.%s.%s" % [str(major), str(minor), str(patch)]

func type_to_string() -> String:
	return VersionType.keys()[type].replace("_", "-")
