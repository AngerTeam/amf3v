module main

import amf3v
import os

fn test_read_array() {
	mut writer := amf3v.open_write()

	mut array := amf3v.AmfArray{}
	array.associative_elements["element1"] = 123

	mut array2 := amf3v.AmfArray{}
	array2.dense_elements << array
	array2.dense_elements << array
	array2.dense_elements << array
	writer.write(array2)

	dump(writer.bytes())
}
