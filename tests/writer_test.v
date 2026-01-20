module main

import amf3v
import os

fn test_read_array() {
	mut writer := amf3v.open_write()

	mut array := amf3v.AmfArray{}
	array.associative_elements["element1"] = 123

	writer.write(array)

	dump(writer.bytes())
}
