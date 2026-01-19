module main

import amf3v
import os

fn test_read_array() {
	file := os.read_bytes('./test_files/deploy_3.441.0_en_android_atc.amf3')!

	mut reader := amf3v.open(file)
	obj := amf3v.read(mut reader)

	assert obj is amf3v.AmfArray

	array := obj as amf3v.AmfArray
	assert array.associative_elements.len == 5
	assert array.dense_elements.len == 0
}
