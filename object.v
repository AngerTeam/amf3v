module amf3v

pub struct AmfTrait {
pub mut:
	class_name string
	dynamic bool
	extern bool
	member_names []string
}

pub struct AmfObject {
pub mut:
	properties map[string]AmfAny
}
