module amf3v

struct ByteWriter {
mut:
	data []u8
	idx int

	string_table []string
	object_table []AmfAny
	traits_table []AmfTrait
}

fn (mut writer ByteWriter) put_u8(b u8) {
	writer.data << b
}

fn (mut writer ByteWriter) put_bytes(b []u8) {
	writer.data << b
}

// Returns the bytes of the written Amf3 object(s)
pub fn (mut writer ByteWriter) bytes() []u8 {
	return writer.data
}
