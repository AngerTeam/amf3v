module amf3v

pub struct AmfArray {
pub mut:
	associative_elements map[string]AmfAny
	dense_elements []AmfAny
}
