module amf3v

import encoding.binary

struct ByteReader {
	data []u8
mut:
	idx int
}

fn (mut reader ByteReader) get_u8() u8 {
	idx := reader.idx
	reader.idx += 1
	return reader.data[idx]
}

fn (mut reader ByteReader) get_u64() u64 {
	len := int(sizeof(u64))
	idx := reader.idx
	reader.idx += len
	return binary.little_endian_u64(reader.data[idx..idx+len])
}

fn (mut reader ByteReader) get_bytes(len int) []u8 {
	idx := reader.idx
	reader.idx += len
	return reader.data[idx..idx+len]
}
