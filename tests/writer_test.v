module main

import amf3v
import os

fn test_write_array() {
	mut writer := amf3v.open_write()

	mut array := amf3v.AmfArray{}
	array.associative_elements["A"] = 2
	array.associative_elements["B"] = 1
	array.dense_elements << false
	array.dense_elements << true
	array.dense_elements << 0

	mut array2 := amf3v.AmfArray{}
	array2.dense_elements << array
	array2.dense_elements << array

	writer.write(array2)

	mut reader := amf3v.open_read(writer.bytes())
	check_obj := reader.read()
	assert check_obj is amf3v.AmfArray
	assert check_obj as amf3v.AmfArray == array2
}

fn test_write_object_fully_dynamic() {
	mut writer := amf3v.open_write()

	mut object := amf3v.AmfObject{}
	object.traits = amf3v.AmfTrait{
		class_name: "",
		dynamic: true,
		extern: false,
		member_names: []
	}

	object.dynamic_members["cmd"] = "registration_guest"
	object.dynamic_members["result"] = 1

	writer.write(object)

	mut reader := amf3v.open_read(writer.bytes())
	check_obj := reader.read()
	assert check_obj is amf3v.AmfObject
	assert check_obj as amf3v.AmfObject == object
}
