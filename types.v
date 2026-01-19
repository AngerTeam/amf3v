module amf3v

import time

type AmfAny = bool | int | f64 | string | time.Time | AmfArray | AmfObject | []u8
