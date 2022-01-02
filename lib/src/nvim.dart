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
    final Stream<String> out = server.stdout
        .transform<String>(utf8.decoder)
        .transform<String>(const LineSplitter());
    out.listen(io.stdout.writeln);
    //server.stdin.write('hi');
    return server;
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
