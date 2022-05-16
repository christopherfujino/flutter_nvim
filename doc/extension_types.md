https://github.com/neovim/go-client/blob/ef8a8cf9c522f7e16fc9d398781af0f73ddbf2b5/nvim/nvim.go#L681

```
// decodeExt decodes a MsgPack encoded number to go int value.
func decodeExt(p []byte) (int, error) {
	switch {
	case len(p) == 1 && p[0] <= 0x7f:
		return int(p[0]), nil
	case len(p) == 2 && p[0] == 0xcc:
		return int(p[1]), nil
	case len(p) == 3 && p[0] == 0xcd:
		return int(uint16(p[2]) | uint16(p[1])<<8), nil
	case len(p) == 5 && p[0] == 0xce:
		return int(uint32(p[4]) | uint32(p[3])<<8 | uint32(p[2])<<16 | uint32(p[1])<<24), nil
	case len(p) == 2 && p[0] == 0xd0:
		return int(int8(p[1])), nil
	case len(p) == 3 && p[0] == 0xd1:
		return int(int16(uint16(p[2]) | uint16(p[1])<<8)), nil
	case len(p) == 5 && p[0] == 0xd2:
		return int(int32(uint32(p[4]) | uint32(p[3])<<8 | uint32(p[2])<<16 | uint32(p[1])<<24)), nil
	case len(p) == 1 && p[0] >= 0xe0:
		return int(int8(p[0])), nil
	default:
		return 0, fmt.Errorf("go-client/nvim: error decoding extension bytes %x", p)
	}
}
```

```
ext 8 stores an integer and a byte array whose length is up to (2^8)-1 bytes:
+--------+--------+--------+========+
|  0xc7  |XXXXXXXX|  type  |  data  |
+--------+--------+--------+========+

where
* XXXXXXXX is a 8-bit unsigned integer which represents N
* YYYYYYYY_YYYYYYYY is a 16-bit big-endian unsigned integer which represents N
* ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ is a big-endian 32-bit unsigned integer which represents N
* N is a length of data
* type is a signed 8-bit signed integer
* type < 0 is reserved for future extension including 2-byte type information
```
