import 'dart:io' as io;
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:messagepack/messagepack.dart';

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
}
