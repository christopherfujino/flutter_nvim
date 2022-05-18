import 'dart:io' as io;
import 'package:dart_nvim/dart_nvim.dart' show NeoVim;
import 'package:dart_nvim/src/api_calls.dart';
import 'package:dart_nvim/src/common.dart';
import 'package:dart_nvim/src/events.dart';

Future<void> main(List<String> args) async {
  final Logger logger = Logger();
  final NeoVim nvim = NeoVim(logger: logger);
  nvim.notifications.listen((Event event) {
    print(event);
  });
  final io.Process process = await nvim.process;
  logger.printStatus('spawned nvim with PID ${process.pid}');
  final ApiInfoResponse _ = await nvim.getApiInfo();

  await nvim.uiAttach(5, 5);
  await nvim.dispose();
  logger.printStatus(
    'nvim process exited with code ${await (await nvim.process).exitCode}',
  );
}
