import 'dart:io' as io;

import 'package:flutter_nvim/src/nvim.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messagepack/messagepack.dart';


void main() {
  test('foo', () async {
    final NeoVim nvim = await NeoVim.asyncFactory();
    final io.Process process = nvim.process;
    await nvim.getApiInfo();

    await nvim.uiAttach(5, 5);

    // note this will never exit unless we explicitly kill the child
    final int code = await process.exitCode;
  });
}
