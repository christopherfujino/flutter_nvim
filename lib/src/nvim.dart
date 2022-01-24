import 'dart:async' show Completer;
import 'dart:io' as io;
import 'dart:typed_data' show Uint8List;

import 'api_calls.dart' show ApiCalls;
import 'logging.dart' show Logging;

import 'package:messagepack/messagepack.dart' as msg;

const int REQUEST = 0;
const int RESPONSE = 1;
const int NOTIFICATION = 2;

class NeoVim extends NeoVimInterface with ApiCalls, Logging {
  NeoVim._() : super() {
    for (final Initializer initializer in initializers) {
      initializer(this);
    }
  }

  static final List<Initializer> initializers = <Initializer>[];

  /// Ensure consumers do not use a [NeoVim] instance until it is initialized.
  static Future<NeoVim> asyncFactory() async {
    final NeoVim instance = NeoVim._();
    instance.process = await instance.futureProcess;
    return instance;
  }
}

typedef Initializer = void Function(NeoVim);

// Only for use by mixins.
abstract class NeoVimInterface {
  NeoVimInterface()
      : futureProcess = _spawnServer(
          <String>['--embed'],
          env: <String, String>{'VIMINIT': 'echo \'yolo dawg!\''},
      ) {
    futureProcess.onError((Object error, StackTrace stacktrace) {
      throw 'Whoopsies!\n$error';
    });
    futureProcess.then((io.Process process) {
      process.stdout.listen((List<int> data) {
        _parseResponse(data);
      });
      process.stderr.listen((List<int> data) {
        printError('got some error!');
        printError('data');
      });
    });

  }

  // These implemented in [./logging.dart]
  void printStatus(String message);
  void printError(String message);

  static const String binary = 'nvim';
  final io.HttpClient client = io.HttpClient();
  final Map<int, Completer<Response>> _responseCompleters =
      <int, Completer<Response>>{};

  final Future<io.Process> futureProcess;

  // As a performance optimization, this is populated once [futureProcess]
  // finishes. Consumers MUST instantiate [NeoVim] objects via [asyncFactory],
  // to ensure [process] is non-null.
  late final io.Process process;

  int _nextMsgid = 0;
  int get nextMsgid {
    _nextMsgid += 1;
    return _nextMsgid - 1;
  }

  Future<Response> sendRequest(
    String method,
    List<String> params,
    io.IOSink sink,
  ) async {
    final int msgid = nextMsgid;
    final Uint8List requestBytes = _buildRequest(msgid, method, params);
    final Completer<Response> completer = Completer<Response>();
    // call server
    // must add binary data, not utf8 text
    sink.add(requestBytes);
    _responseCompleters[msgid] = completer;
    await sink.flush(); // do we need to do this?
    return completer.future;
  }

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

  // Note return value probably not needed
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
    final Completer<Response>? completer = _responseCompleters[msgid];
    if (completer == null) {
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
    completer.complete(response);

    return response;
  }

  static Future<io.Process> _spawnServer(
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
