import 'dart:io' as io;
import 'package:flutter_nvim/flutter_nvim.dart' show NeoVim;

Future<void> main(List<String> args) async {
  final NeoVim neoVim = NeoVim();
  final io.Process nvim = await neoVim.main();
  io.stdout.writeln('spawned nvim with PID ${nvim.pid}');
  final int code = await nvim.exitCode;
  io.stdout.writeln('nvim exited with code $code');
}
