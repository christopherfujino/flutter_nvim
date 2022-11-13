import 'dart:io' as io;

class Logger {
  const Logger([this.verbose = true]);

  final bool verbose;

  void printTrace(Object? msg) {
    io.stdout.writeln(msg?.toString());
  }

  void printStatus(Object? msg) {
    io.stdout.writeln(msg?.toString());
  }

  void printError(Object? msg) {
    io.stderr.writeln(msg?.toString());
  }
}

class NoOpLogger implements Logger {
  const NoOpLogger();

  final bool verbose = false;

  void printTrace(Object? msg) {}

  void printStatus(Object? msg) {}

  void printError(Object? msg) {}
}

class BufferLogger implements Logger {
  final bool verbose = false;

  StringBuffer trace = StringBuffer();
  StringBuffer status = StringBuffer();
  StringBuffer error = StringBuffer();

  void printTrace(Object? msg) {
    trace.writeln(msg?.toString());
  }

  void printStatus(Object? msg) {
    status.writeln(msg?.toString());
  }

  void printError(Object? msg) {
    error.writeln(msg?.toString());
  }
}
