import 'dart:async' show Completer;
import 'dart:io' as io;
import 'dart:typed_data';
//import 'dart:convert' show utf8, LineSplitter;

import 'package:messagepack/messagepack.dart' as msg;

const int REQUEST = 0;
const int RESPONSE = 1;
const int NOTIFICATION = 2;

class NeoVim {
  NeoVim()
      : futureServer = spawnServer(
          <String>['--embed'],
          env: <String, String>{'VIMINIT': 'echo \'yolo dawg!\''},
        ) {
    futureServer.onError((Object error, StackTrace stacktrace) {
      throw 'Whoopsies!\n$error';
    });
  }

  static const String binary = 'nvim';
  final io.HttpClient client = io.HttpClient();
  final Map<int, Completer<Response>> _responseCompleters =
      <int, Completer<Response>>{};

  final Future<io.Process> futureServer;

  Future<io.Process> main() async {
    try {
      final io.Process server = await futureServer;
      final Stream<List<int>> out = server.stdout;
      out.listen((List<int> data) {
        io.stdout.writeln('got some data!');
        final response = _parseResponse(data);
        io.stdout.write(response.toString());
        //io.stdout.writeln(_fromIntsToString(data));
      });
      final Stream<List<int>> err = server.stderr;
      err.listen((List<int> data) {
        io.stdout.writeln('got some error!');
        io.stdout.writeln(data);
      });
      //_sendStringToSink('[$REQUEST, 42, "nvim_get_api_info", []]', server.stdin);
      final Future<Response> response =
          _sendRequest('nvim_get_api_info', [], server.stdin);
      print(await response);
      return server;
    } finally {
      futureServer.then((io.Process server) {
        final bool success = server.kill(io.ProcessSignal.sigkill);
        if (success) {
          print('successfully killed nvim process.');
        } else {
          print('nvim already dead');
        }
      });
    }
  }

  int _nextMsgid = 0;
  int get nextMsgid {
    _nextMsgid += 1;
    return _nextMsgid - 1;
  }

  Future<Response> _sendRequest(
      String method, List<String> params, io.IOSink sink) async {
    final int msgid = nextMsgid;
    final Uint8List requestBytes = _buildRequest(msgid, method, params);
    final Completer<Response> completer = Completer<Response>();
    // call server
    // must add binary data, not utf8 text
    sink.add(requestBytes);
    _responseCompleters[msgid] = completer;
    await sink.flush();
    return completer.future;
  }

  // TODO should these be a future response?
  // TODO do params need to be List<Object?>?
  // [type, msgid, method, params]
  // https://github.com/msgpack-rpc/msgpack-rpc/blob/master/spec.md#request-message
  Uint8List _buildRequest(int msgid, String method, List<String> params) {
    final msg.Packer packer = msg.Packer();

    // [type, msgid, method, params]
    packer.packListLength(4);
    packer.packInt(REQUEST);

    // A 32-bit unsigned integer number. This number is used as a sequence
    // number. The server's response to the "Request" will have the same msgid.
    packer.packInt(msgid);

    packer.packString(method);

    // how to handle 0?
    packer.packListLength(params.length);
    for (final String param in params) {
      packer.packString(param);
    }
    return packer.takeBytes();
  }

  AbstractResponse _parseResponse(List<int> bytes) {
    final msg.Unpacker unpacker = msg.Unpacker.fromList(bytes);
    final List<Object?> messageList = unpacker.unpackList();
    final int type = messageList[0] as int;
    if (type == NOTIFICATION) {
      throw 'notification unimplemented';
    } else if (type != RESPONSE) {
      throw 'huh?! $type';
    }
    final int msgid = messageList[1] as int;
    if (!_responseCompleters.containsKey(msgid)) {
      throw 'not expecting msgid $msgid!';
    }
    if (messageList[2] != null) {
      throw RPCError.fromList(messageList[2]!);
      //return Response(
      //  msgid: msgid,
      //  error: RPCError.fromList(messageList[2]!),
      //  result: null, // either error or result will be null
      //);
    }
    final response = Response(
      msgid: msgid,
      error: null,
      result: messageList[3],
    );
    _responseCompleters[msgid]!.complete(response);

    return response;
  }

  static Future<io.Process> spawnServer(
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

/// One of [Response] or [Notification].
abstract class AbstractResponse {
  const AbstractResponse(this.type);

  final int type;
}

class Response extends AbstractResponse {
  const Response({
    required this.msgid,
    required this.error,
    required this.result,
  }) : super(RESPONSE);

  final int msgid;
  final Object? error;
  final Object? result;

  @override
  String toString() => '''
msgid: $msgid
error: $error
result: $result
''';
}

// :help nvim_error_event
class RPCError implements Exception {
  const RPCError({
    required this.type,
    required this.message,
  });

  factory RPCError.fromList(Object tuple) {
    final List<Object?> list = tuple as List<Object?>;
    return RPCError(
      type: list[0] as int,
      message: list[1] as String,
    );
  }

  final int type;
  final String message;

  @override
  String toString() => '''
RPCError: $message
''';
}
