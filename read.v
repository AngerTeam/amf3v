module amf3v

pub fn read_double(mut reader ByteReader) f64 {
	return int64_bits_to_double(reader.get_u64())
}

pub fn read_packed_int(mut reader ByteReader) int {
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

pub fn read_flagged_int(mut reader ByteReader) (int, bool) {
	num := read_packed_int(mut reader)
	// println("[read_flagged_int] num ${num} | ${(num >> 1)} | ${(num & 1) == 1}")
	return (num >> 1), (num & 1) == 1
}

pub fn read_string(mut reader ByteReader) string {
	value, flagged := read_flagged_int(mut reader)
	if flagged {
		string_data := reader.get_bytes(value)
		if string_data.len < value {
			panic("End of stream!")
		}
		str := string_data.bytestr()
		// println("[read_string] ${str}")
		return str
	}
	return ""
}

pub fn read_property_list(mut reader ByteReader) map[string]AmfAny {
	mut properties := map[string]AmfAny{}

	for {
		text := read_string(mut reader)
		if text == "" {
			break
		}
		obj := read(mut reader)
		properties[text] = obj
	}

	return properties
}

pub fn read(mut reader ByteReader) AmfAny {
	type := reader.get_u8()

	// println("[read] type ${type}")

	if type == amf_false {
		return false
	} else if type == amf_true {
		return true
	} else if type == amf_packed_int {
		return read_packed_int(mut reader)
	} else if type == amf_double {
		return read_double(mut reader)
	} else if type == amf_string {
		return read_string(mut reader)
	} else if type == amf_array {
		value, flagged := read_flagged_int(mut reader)
		if flagged {
			mut array := AmfArray{}
			array.associative_elements = read_property_list(mut reader)

			for _ in 0..value {
				array.dense_elements << read(mut reader)
			}

			return array
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
