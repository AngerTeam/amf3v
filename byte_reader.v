module amf3v

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

fn (mut reader ByteReader) get_i64() i64 {
	// TODO: implement
	idx := reader.idx
	reader.idx += int(sizeof(i64))
	return 0 //reader.data[idx]
}

fn (mut reader ByteReader) get_bytes(len int) []u8 {
	idx := reader.idx
	reader.idx += len
	return reader.data[idx..idx+len]
}
