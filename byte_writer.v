module amf3v

struct ByteWriter {
mut:
	data []u8
	idx int

	string_table map[string]int
	object_table []AmfAny
}

fn (mut writer ByteWriter) put_u8(b u8) {
	writer.data << b
}

fn (mut writer ByteWriter) put_bytes(b []u8) {
	writer.data << b
}

pub fn (mut writer ByteWriter) bytes() []u8 {
	return writer.data
}
