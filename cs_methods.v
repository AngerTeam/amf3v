module amf3v

import encoding.binary

fn u8_array_to_double(b []u8) f64 {
	decoded := binary.decode_binary[f64](b) or { 0.0 }
	return decoded
}

fn int64_bits_to_double(value u64) f64 {
	encoded := binary.encode_binary[u64](value) or { [u8(0)] }
	decoded := binary.decode_binary[f64](encoded) or { 0.0 }
	return decoded
}
