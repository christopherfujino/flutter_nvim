import 'dart:io' as io;

import 'dart:async' show StreamController, StreamSubscription;

import 'nvim.dart';

mixin Logging on NeoVimInterface {
  static final void dummy = (() {
    NeoVim.initializers.add((NeoVim nvim) {
      initializeLogging(nvim);
    });
  })();

  // MUST be called on object construction.
  static void initializeLogging(NeoVim nvim, [io.IOSink? stdout]) {
    stdout ??= io.stdout;
    nvim._logController.onListen = () {
      nvim._logsHaveListener = true;
      for (final String message in nvim._startupLogBuffer) {
        stdout!.writeln(message);
      }
    };
    nvim.listen((String message) {
      if (!nvim._logsHaveListener) {
        nvim._startupLogBuffer.add(message);
      } else {
        stdout!.writeln(message);
      }
    });
  }

  final StreamController<String> _logController = StreamController<String>();

  final List<String> _startupLogBuffer = <String>[];
  bool _logsHaveListener = false;

  // The return value usually does not need to be used.
  StreamSubscription listen(void Function(String) callback) {
    return _logController.stream.listen(callback);
  }

  @override
  void printStatus(String message) {
    _logController.add('$message\n');
  }

  @override
  void printError(String message) {
    _logController.add('$message\n');
  }
}
