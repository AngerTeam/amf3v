module amf3v

pub fn (mut reader ByteReader) read_double() !f64 {
	return int64_bits_to_double(reader.get_u64()!)
}

pub fn (mut reader ByteReader) read_packed_int() !int {
	b := reader.get_u8()!
	mut num := int(0x7F & b)
	if b & 0x80 == 0 {
		return num
	}

	b2 := reader.get_u8()!
	num = (num << 7) | (0x7F & b2)
	if b2 & 0x80 == 0 {
		return num
	}

	b3 := reader.get_u8()!
	num = (num << 7) | (0x7F & b3)
	if b3 & 0x80 == 0 {
		return num
	}

	b4 := reader.get_u8()!
	return (num << 8) | b4
}

pub fn (mut reader ByteReader) read_flagged_int() !(int, bool) {
	num := reader.read_packed_int()!
	// println("[read_flagged_int] num ${num} | ${(num >> 1)} | ${(num & 1) == 1}")
	return num >> 1, (num & 1) == 1
}

pub fn (mut reader ByteReader) read_string() !string {
	value, flagged := reader.read_flagged_int()!
	if flagged {
		string_data := reader.get_bytes(value)!
		if string_data.len < value {
			return error('End of stream!')
		}
		str := string_data.bytestr()
		reader.string_table << str
		return str
	} else {
		return reader.string_table[value]
	}
	return ''
}

pub fn (mut reader ByteReader) read_property_list() !map[string]AmfAny {
	mut properties := map[string]AmfAny{}

	for {
		text := reader.read_string()!
		if text == '' {
			break
		}
		obj := reader.read()!
		properties[text] = obj
	}

	return properties
}

pub fn (mut reader ByteReader) read_traits(value int) !AmfTrait {
	first_time := (value & 1) == 1
	arg1 := value >> 1

	if first_time {
		mut traits := AmfTrait{}

		class_name := reader.read_string()!
		is_extern := (arg1 & 1) == 1
		arg2 := arg1 >> 1

		traits.class_name = class_name
		if is_extern {
			traits.extern = true
		} else {
			is_dynamic := (arg2 & 1) == 1
			member_names_count := arg2 >> 1

			mut member_names := []string{len: member_names_count}
			for i in 0 .. member_names_count {
				member_names[i] = reader.read_string()!
			}

			traits.member_names = member_names
			traits.dynamic = is_dynamic
		}

		reader.traits_table << traits
		return traits
	}

	return reader.traits_table[arg1]
}

pub fn (mut reader ByteReader) read_object() !AmfObject {
	value, flagged := reader.read_flagged_int()!
	if flagged {
		mut object := AmfObject{}
		traits := reader.read_traits(value)!
		if traits.extern {
			return error('Unimplemented extern amf object ${traits.class_name}')
		}

		object.traits = traits

		for key in traits.member_names {
			object.static_members[key] = reader.read()!
		}

		if traits.dynamic {
			for {
				name := reader.read_string()!
				if name == '' {
					break
				}
				object.dynamic_members[name] = reader.read()!
			}
		}

		reader.object_table << object
		return object
	} else {
		return reader.object_table[value] as AmfObject
	}
	return AmfObject{}
}

// Reads the next Amf3 object in the file
pub fn (mut reader ByteReader) read() !AmfAny {
	type := reader.get_u8()!

	// println("[read] type ${type}")

	if type == amf_false {
		return false
	} else if type == amf_true {
		return true
	} else if type == amf_packed_int {
		return reader.read_packed_int()!
	} else if type == amf_double {
		return reader.read_double()!
	} else if type == amf_string {
		return reader.read_string()!
	} else if type == amf_array {
		value, flagged := reader.read_flagged_int()!
		if flagged {
			mut array := AmfArray{}
			array.associative_elements = reader.read_property_list()!

			for _ in 0 .. value {
				array.dense_elements << reader.read()!
			}

			reader.object_table << array
			return array
		} else {
			return reader.object_table[value]
		}
		return AmfArray{}
	} else if type == amf_object {
		return reader.read_object()!
	}

	return error('Undefined type ID ${type}')
}

// Creates a reader instance with `data` as the bytes it's reading
pub fn open_read(data []u8) ByteReader {
	mut reader := ByteReader{
		data: data
	}

	return reader
}
