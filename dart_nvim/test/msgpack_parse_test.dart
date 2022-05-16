import 'dart:io' as io;
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:messagepack/messagepack.dart';

import 'test_data/msgpack_extension_message.dart' show testMessage;

void main() {
  test('can parse redraw notification', () async {
    final io.File redrawMessageBin = io.File(
      'test/test_data/redraw_message.bin',
    );
    final Uint8List redrawMessageBytes = await redrawMessageBin.readAsBytes();
    final Unpacker unpacker = Unpacker.fromList(redrawMessageBytes);
    final listLength = unpacker.unpackListLength();
    expect(listLength, 3); // This is notification?
    final type = unpacker.unpackInt();
    expect(type, 2); // notification
    final method = unpacker.unpackString();
    expect(method, 'redraw');
    final paramLength = unpacker.unpackListLength();
    expect(paramLength, 81);
    var unpackedLists = <List>[];
    for (var i = 0; i < paramLength; i += 1) {
      try {
        unpackedLists.add(unpacker.unpackList());
      } on FormatException {
        final StringBuffer buffer = StringBuffer('[\n');
        unpackedLists.forEach((List<dynamic> tuple) {
          buffer.writeln('  $tuple,');
        });
        buffer.writeln(']');
        print(buffer);
        print('current offset is ${unpacker.offset}');
        rethrow;
      }
    }
  });

  // ext 8 stores an integer and a byte array whose length is up to (2^8)-1 bytes:
  // +--------+--------+--------+========+
  // |  0xc7  |XXXXXXXX|  type  |  data  |
  // +--------+--------+--------+========+
  //
  // where
  // * XXXXXXXX is a 8-bit unsigned integer which represents N
  // * YYYYYYYY_YYYYYYYY is a 16-bit big-endian unsigned integer which represents N
  // * ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ is a big-endian 32-bit unsigned integer which represents N
  // * N is a length of data
  // * type is a signed 8-bit signed integer
  // * type < 0 is reserved for future extension including 2-byte type information
  test('diagnose ext8', () {
    const int start = 1226;
    const int ext8Type = 0xc7;
    expect(testMessage[start], ext8Type);
    // N is a length of data
    final int n = testMessage[start + 1]; // length
    expect(n, 3);
    // type is a signed 8-bit integer (?!)
    final int type = testMessage[start + 2];
    printOnFailure('n == $n');
    printOnFailure('type == $type');
    for (int j = 0; j < (n + 3); j += 1) {
      final int element = testMessage[start + j];
      printOnFailure(
        '  [${start + j}]:\t$element\t0x${element.toRadixString(16)}',
      );
    }

    // n == 3
    // type == 1
    //         [1226]: 199     0xc7
    //         [1227]: 3       0x3
    //         [1228]: 1       0x1
    //         [1229]: 205     0xcd
    //         [1230]: 3       0x3
    //         [1231]: 232     0xe8
  }, skip: false);

  test('diagnose offset 2423', () async {
    // 2423: 0xc7
    // 2424: 0x03 // length
    // 2425: 0x01 // type == window
    // 2426: 0xcd // data[0]
    // 2427: 0x03 // data[1]
    // 2428: 0xe8 // data[2]
    // 2429: 0x00
    // 2430: 0x01
    // 2431: 0x00
    // 2432: 0x00
    // 2433: 0x01
    // 2434: 0xdc
    // 2435: 0x00
    // 2436: 0x32
    // 2437: 0xac
    // 2438: 0x68
    // 2439: 0x6c
    // 2440: 0x5f
    // 2441: 0x67
    // 2442: 0x72

    final io.File redrawMessageBin =
        io.File('test/test_data/redraw_message.bin');
    final Uint8List redrawMessageBytes = await redrawMessageBin.readAsBytes();
    const int start = 2423;
    const int fooType = 0x6f;
    for (int idx = start; idx < (start + 20); idx += 1) {
      final int i = redrawMessageBytes[idx];
      print('$idx: 0x${i.toRadixString(16).padLeft(2, '0')}');
    }
    fail('fail');
    //expect(redrawMessageBytes[start], fooType); // ??
    // N is a length of data
    final int n = testMessage[start + 1]; // length
    expect(n, 3);
    // type is a signed 8-bit integer (?!)
    final int type = testMessage[start + 2];
    printOnFailure('n == $n');
    printOnFailure('type == $type');
    for (int j = 0; j < (n + 3); j += 1) {
      final int element = testMessage[start + j];
      printOnFailure(
        '\t[${start + j}]:\t$element\t0x${element.toRadixString(16)}',
      );
    }

    // ext 8 stores an integer and a byte array whose length is up to (2^8)-1 bytes:
    // +--------+--------+--------+========+
    // |  0xc7  |XXXXXXXX|  type  |  data  |
    // +--------+--------+--------+========+
    //
    // where
    // * XXXXXXXX is a 8-bit unsigned integer which represents N
    // * YYYYYYYY_YYYYYYYY is a 16-bit big-endian unsigned integer which represents N
    // * ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ_ZZZZZZZZ is a big-endian 32-bit unsigned integer which represents N
    // * N is a length of data
    // * type is a signed 8-bit signed integer
    // * type < 0 is reserved for future extension including 2-byte type information
  }, skip: false);
}
