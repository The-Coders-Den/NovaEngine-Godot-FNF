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

func _init(_major:int = 0, _minor:int = 0, _patch:int = 1, _type:VersionType = VersionType.DEV):
	self.major = _major
	self.minor = _minor
	self.patch = _patch
	self.type = _type

# allows you to do str(Global.VERSION)
func _to_string() -> String:
	return "v%s.%s.%s" % [str(major), str(minor), str(patch)]

func type_to_string() -> String:
	return VersionType.keys()[type].replace("_", "-")
