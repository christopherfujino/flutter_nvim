import 'dart:io' as io;
import 'package:dart_nvim/dart_nvim.dart' show NeoVim;
import 'package:dart_nvim/src/api_calls.dart';

Future<void> main(List<String> args) async {
  final NeoVim nvim = await NeoVim.asyncFactory();
  final io.Process process = nvim.process;
  io.stdout.writeln('spawned nvim with PID ${process.pid}');
  final ApiInfoResponse _ = await nvim.getApiInfo();

  await nvim.uiAttach(5, 5);
  // note this will never exit unless we explicitly kill the child
  //final int code = await process.exitCode;
  //io.stdout.writeln('nvim exited with code $code');
}
