module amf3v

// Struct that represents an Amf3 object's traits
pub struct AmfTrait {
pub mut:
	class_name string
	dynamic bool
	extern bool
	member_names []string
}

// Struct that represents an Amf3 object
pub struct AmfObject {
pub mut:
	traits AmfTrait
	properties map[string]AmfAny
}
