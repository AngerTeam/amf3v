# amf3v
[AMF3](https://en.wikipedia.org/wiki/Action_Message_Format#AMF3) reader/writer library in V

# Examples
## Reading
```v
module main
import amf3v
import os

fn main() {
  data := os.read_bytes("./data.amf3")!
  mut reader := amf3v.open_read(data)
  obj := reader.read()!
}
```

## Writing
```v
module main
import amf3v
import os

fn main() {
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

	writer.write(array2)!
	os.write_bytes("./data.amf3", writer.bytes())!
}
```

For more examples, you can look at the 'tests' folder.
