import 'dart:io' as io;
import 'package:flutter_nvim/flutter_nvim.dart' show NeoVim;

Future<void> main(List<String> args) async {
  final NeoVim nvim = await NeoVim.asyncFactory();
  final io.Process process = nvim.process;
  io.stdout.writeln('spawned nvim with PID ${process.pid}');
  await nvim.getApiInfo();

  // note this will never exit unless we explicitly kill the child
  final int code = await process.exitCode;
  io.stdout.writeln('nvim exited with code $code');
}
