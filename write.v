module amf3v

fn (mut writer ByteWriter) write_packed_integer(value int) {
	if value < 0 {
		panic("An attempt was made to serialize a negative integer.")
	}

	if value < 128 {
		writer.put_u8(u8(value))
		return
	}

	if value < 16384 {
		writer.put_u8(u8(0x80 | (u8(value >> 7) & 0x7f)))
		writer.put_u8(u8(value & 0x7f))
		return
	}

	if value < 2097152 {
		writer.put_u8(u8(0x80 | (u8(value >> 14) & 0x7f)))
		writer.put_u8(u8(0x80 | (u8(value >> 7) & 0x7f)))
		writer.put_u8(u8(value & 0x7f))
		return
	}

	if value < 1073741824 {
		writer.put_u8(u8(0x80 | (u8(value >> 22) & 0x7f)))
		writer.put_u8(u8(0x80 | (u8(value >> 15) & 0x7f)))
		writer.put_u8(u8(0x80 | (u8(value >> 8) & 0x7f)))
		writer.put_u8(u8(value & 0x7f))
		return
	}

	panic("An integer too large to serialize was serialized.")
}

fn (mut writer ByteWriter) write_flagged_integer(value int, flag bool) {
	writer.write_packed_integer((value << 1) | (if flag { 1 } else { 0 }))
}

fn (mut writer ByteWriter) write_string(value string) {
	if value in writer.string_table {
		idx := writer.string_table.index(value)
		writer.write_flagged_integer(idx, false)
		return
	}

	if value != "" {
		writer.string_table << value
	}

	writer.write_flagged_integer(value.len, true)
	writer.put_bytes(value.bytes())
}

pub fn (mut writer ByteWriter) write(object AmfAny) {
	type := match object {
		bool {
			as_bool := object as bool
			if as_bool { amf_true } else { amf_false }
		}
		int { amf_packed_int }
		f64 { amf_double }
		string { amf_string }
		AmfArray { amf_array }
		else { amf_undefined }
	}

	writer.put_u8(u8(type))

	match type {
		amf_packed_int {
			as_int := object as int
			writer.write_packed_integer(as_int)
		}
		amf_string {
			as_string := object as string
			writer.write_string(as_string)
		}
		amf_array {
			if !(object in writer.object_table) {
				as_array := object as AmfArray
				writer.write_flagged_integer(as_array.dense_elements.len, true)
				for k,v in as_array.associative_elements {
					writer.write_string(k)
					writer.write(v)
				}
				writer.write_string("")
				for obj in as_array.dense_elements {
					writer.write(obj)
				}
				writer.object_table << object
			} else {
				idx := writer.object_table.index(object)
				writer.write_flagged_integer(idx, false)
			}
		}
		else { return }
	}
}

pub fn open_write() ByteWriter {
	mut writer := ByteWriter{}

	return writer
}
