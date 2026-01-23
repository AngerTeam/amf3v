module main

import amf3v
import os

fn test_read_array() {
	file := os.read_bytes('./test_files/deploy_3.441.0_en_android_atc.amf3')!

	mut reader := amf3v.open_read(file)
	obj := reader.read()

	// check if return type is correct
	assert obj is amf3v.AmfArray

	// check if array info is correct
	array := obj as amf3v.AmfArray
	assert array.associative_elements.len == 5
	assert array.dense_elements.len == 0

	// check if keys are correct
	assert array.associative_elements.keys()[0] == "ab_tests"
	assert array.associative_elements.keys()[1] == "ab_test_variants"
	assert array.associative_elements.keys()[2] == "ab_test_id"
	assert array.associative_elements.keys()[3] == "number"
	assert array.associative_elements.keys()[4] == "weight"

	// check if nested arrays are correct
	assert array.associative_elements["ab_tests"] is amf3v.AmfArray
	ab_tests := array.associative_elements["ab_tests"] as amf3v.AmfArray
	assert ab_tests.dense_elements.len == 1
	assert ab_tests.dense_elements[0] is amf3v.AmfArray
	ab_test_1 := ab_tests.dense_elements[0] as amf3v.AmfArray
	assert ab_test_1.associative_elements.keys()[0] == "id"
	assert ab_test_1.associative_elements.keys()[1] == "code"
	assert ab_test_1.associative_elements.keys()[2] == "status"
	assert ab_test_1.associative_elements.keys()[3] == "percent"
	assert ab_test_1.associative_elements.keys()[4] == "allow_new_user"
	assert ab_test_1.associative_elements.keys()[5] == "days_in_game"
	assert ab_test_1.associative_elements.keys()[6] == "start_ts"
	assert ab_test_1.associative_elements.keys()[7] == "end_ts"
}

fn test_read_object() {
	file := os.read_bytes('./test_files/login_packet.amf3')!

	mut reader := amf3v.open_read(file)
	obj := reader.read()

	// check if return type is correct
	assert obj is amf3v.AmfObject

	// check if object info is correct
	object := obj as amf3v.AmfObject
	assert object.static_members.len == 0
	assert object.dynamic_members.len == 9

	// check if dynamic members are correct
	assert object.dynamic_members.keys()[0] == "pf"
	assert object.dynamic_members.keys()[1] == "locale"
	assert object.dynamic_members.keys()[2] == "udid"
	assert object.dynamic_members.keys()[3] == "client_version"
	assert object.dynamic_members.keys()[4] == "bid"
	assert object.dynamic_members.keys()[5] == "not_from_store"
	assert object.dynamic_members.keys()[6] == "cmd"
	assert object.dynamic_members.keys()[7] == "ts"
	assert object.dynamic_members.keys()[8] == "sig"

	// check random field
	assert object.dynamic_members["cmd"] is string
	assert object.dynamic_members["cmd"] as string == "registration_guest"
}
