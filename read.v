module amf3v

pub fn (mut reader ByteReader) read_double() f64 {
	return int64_bits_to_double(reader.get_u64())
}

pub fn (mut reader ByteReader) read_packed_int() int {
	b := reader.get_u8()
	mut num := int(0x7F & b)
	if b & 0x80 == 0 { return num }

	b2 := reader.get_u8()
	num = (num << 7) | (0x7F & b2)
	if b2 & 0x80 == 0 { return num }

	b3 := reader.get_u8()
	num = (num << 7) | (0x7F & b3)
	if b3 & 0x80 == 0 { return num }

	b4 := reader.get_u8()
	return (num << 8) | b4
}

pub fn (mut reader ByteReader) read_flagged_int() (int, bool) {
	num := reader.read_packed_int()
	// println("[read_flagged_int] num ${num} | ${(num >> 1)} | ${(num & 1) == 1}")
	return (num >> 1), (num & 1) == 1
}

pub fn (mut reader ByteReader) read_string() string {
	value, flagged := reader.read_flagged_int()
	if flagged {
		string_data := reader.get_bytes(value)
		if string_data.len < value {
			panic("End of stream!")
		}
		str := string_data.bytestr()
		reader.string_table << str
		return str
	} else {
		return reader.string_table[value]
	}
	return ""
}

pub fn (mut reader ByteReader) read_property_list() map[string]AmfAny {
	mut properties := map[string]AmfAny{}

	for {
		text := reader.read_string()
		if text == "" {
			break
		}
		obj := reader.read()
		properties[text] = obj
	}

	return properties
}

pub fn (mut reader ByteReader) read() AmfAny {
	type := reader.get_u8()

	// println("[read] type ${type}")

	if type == amf_false {
		return false
	} else if type == amf_true {
		return true
	} else if type == amf_packed_int {
		return reader.read_packed_int()
	} else if type == amf_double {
		return reader.read_double()
	} else if type == amf_string {
		return reader.read_string()
	} else if type == amf_array {
		value, flagged := reader.read_flagged_int()
		if flagged {
			mut array := AmfArray{}
			array.associative_elements = reader.read_property_list()

			for _ in 0..value {
				array.dense_elements << reader.read()
			}

			reader.object_table << array
			return array
		} else {
			return reader.object_table[value]
		}
		return AmfArray{}
	}

	panic("Undefined type ID ${type}")
}

pub fn open(data []u8) ByteReader {
	mut reader := ByteReader{
		data: data
	}

	return reader
}
