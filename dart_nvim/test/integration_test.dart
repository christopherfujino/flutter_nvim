import 'dart:io' as io;

import 'package:dart_nvim/src/nvim.dart';
import 'package:test/test.dart';


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
