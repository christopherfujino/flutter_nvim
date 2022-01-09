import 'dart:io' as io;
import 'dart:convert' show utf8, LineSplitter;

import 'package:messagepack/messagepack.dart' as msg;

class NeoVim {
  final String binary = 'nvim';
  final io.HttpClient client = io.HttpClient();
  final msg.Packer packer = msg.Packer();

  Future<io.Process> main() async {
    final io.Process server = await spawnServer(
      <String>['--embed'],
      env: <String, String>{'VIMINIT': 'echo \'yolo dawg!\''},
    );
    final Stream<List<int>> out = server.stdout;
    out.listen((List<int> data) {
      io.stdout.writeln('got some data!');
      io.stdout.writeln(_fromIntsToString(data));
    });
    final Stream<List<int>> err = server.stderr;
    err.listen((List<int> data) {
      io.stdout.writeln('got some error!');
      io.stdout.writeln(data);
    });
    _sendStringToSink('["hi"]', server.stdin);
    return server;
  }

  String _fromIntsToString(List<int> integers) {
    StringBuffer buffer = StringBuffer();
    for (final int i in integers) {
      buffer.writeCharCode(i);
    }
    return buffer.toString();
  }

  void _sendStringToSink(String str, io.IOSink sink) {
    for (final int code in str.codeUnits) {
      sink.writeCharCode(code);
    }
  }

  Future<io.Process> spawnServer(
    List<String> args, {
    Map<String, String>? env,
  }) async {
    return await io.Process.start(
      binary,
      args,
      environment: env,
      mode: io.ProcessStartMode.normal,
    );
  }
}
