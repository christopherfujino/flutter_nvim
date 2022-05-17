import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:io' as io;
import 'dart:typed_data' show Uint8List;

import 'api_calls.dart' show ApiCalls;
import 'events.dart' show Events;

import 'package:messagepack/messagepack.dart' as msg;
import 'package:meta/meta.dart';

const int REQUEST = 0;
const int RESPONSE = 1;
const int NOTIFICATION = 2;

class NeoVim extends NeoVimInterface with ApiCalls, Events {
  @visibleForTesting
  NeoVim() : super();

  /// Ensure consumers do not use a [NeoVim] instance until it is initialized.
  static Future<NeoVim> asyncFactory() async {
    final NeoVim instance = NeoVim();
    instance.process = await instance.futureProcess;
    return instance;
  }
}

typedef Initializer = void Function(NeoVim);

// Only for use by mixins.
abstract class NeoVimInterface {
  NeoVimInterface()
      : futureProcess = _spawnServer(
          <String>['-u', 'NONE', '--embed'],
          //    env: <String, String>{'VIMINIT': 'echo \'yolo dawg!\''},
        ) {
    futureProcess.onError((Object error, StackTrace stacktrace) {
      throw 'Whoopsies!\n$error';
    });
    futureProcess.then((io.Process process) {
      _stdoutSub = process.stdout.listen((List<int> data) {
        print('got some data');
        _parseResponse(data);
      });
      _stderrSub = process.stderr.listen((List<int> data) {
        print('got some error!');
        print(utf8.decode(data));
      });
    });
  }

  static const String binary = 'nvim';
  final io.HttpClient client = io.HttpClient();
  final Map<int, Completer<Response>> _responseCompleters =
      <int, Completer<Response>>{};

  final Future<io.Process> futureProcess;

  late final StreamSubscription<List<int>> _stdoutSub;
  late final StreamSubscription<List<int>> _stderrSub;

  // As a performance optimization, this is populated once [futureProcess]
  // finishes. Consumers MUST instantiate [NeoVim] objects via [asyncFactory],
  // to ensure [process] is non-null.
  late final io.Process process;

  void dispose() {
    _stdoutSub.cancel();
    _stderrSub.cancel();
    process.kill();
  }

  int _nextMsgid = 0;
  int get nextMsgid {
    _nextMsgid += 1;
    return _nextMsgid - 1;
  }

  Future<Response> sendRequest(
    String method,
    List<Object?> params,
    io.IOSink sink,
  ) async {
    final int msgid = nextMsgid;
    final Uint8List requestBytes = _buildRequest(msgid, method, params);
    final Completer<Response> completer = Completer<Response>();
    // call server
    // must add binary data, not utf8 text
    sink.add(requestBytes);
    _responseCompleters[msgid] = completer;
    await sink.flush(); // TODO do we need to do this?
    return completer.future;
  }

  // TODO do params need to be List<Object?>?
  // [type, msgid, method, params]
  // https://github.com/msgpack-rpc/msgpack-rpc/blob/master/spec.md#request-message
  Uint8List _buildRequest(int msgid, String method, List<Object?> params) {
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
    for (final Object? param in params) {
      _packObject(param, packer);
    }
    return packer.takeBytes();
  }

  Notification _parseNotification(List<int> bytes, List<Object?> messageList) {
    final int type = messageList[0] as int;
    assert(type == NOTIFICATION);
    final String method = messageList[1] as String;
    final List<Object?> params = messageList[2] as List<Object?>;
    // TODO just directly return this [Notification]
    final Notification notification = Notification(method, params);
    //final io.File redrawBin = io.File('/home/fujino/git/flutter_nvim/dart_nvim/test/test_data/redraw_message.bin');
    //redrawBin.writeAsBytesSync(bytes);
    return notification;
  }

  Future<void> handleNotification(Notification notification);

  void _parseResponse(List<int> bytes) {
    try {
      final msg.Unpacker unpacker = msg.Unpacker.fromList(bytes);
      final List<Object?> messageList = unpacker.unpackList();
      final int type = messageList[0] as int;
      switch (type) {
        case NOTIFICATION:
          unawaited(handleNotification(_parseNotification(bytes, messageList)));
          return;
        case RESPONSE:
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
          return;
        default:
          throw 'huh?! $type';
      }
    } on FormatException {
      final StringBuffer buffer = StringBuffer();
      buffer.write('[');
      buffer.write(bytes.join(', '));
      buffer.write(']');
      final io.File file = io.File('deleteme.txt')
        ..writeAsStringSync(buffer.toString());
      print('wrote file ${file.path} to disk');
      rethrow;
    }
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

void _packObject(Object? obj, msg.Packer packer) {
  if (obj is String) {
    packer.packString(obj);
  } else if (obj is int) {
    packer.packInt(obj);
  } else if (obj is Map) {
    packer.packMapLength(obj.length);
    for (final MapEntry<Object?, Object?> entry in obj.entries) {
      _packObject(entry.key, packer);
      _packObject(entry.value, packer);
    }
  } else if (obj is bool) {
    packer.packBool(obj);
  } else {
    throw Exception('do not know how to pack a ${obj.runtimeType}');
  }
}

/// One of [Response] or [Notification].
abstract class AbstractResponse {
  const AbstractResponse();
}

class Response extends AbstractResponse {
  const Response({
    required this.msgid,
    required this.error,
    required this.result,
  });

  final int msgid;
  final Object? error;
  final Object? result;

  @override
  String toString() => '''
Response:
\tmsgid: $msgid
\terror: $error
\tresult: $result
''';
}

/// Notification Message
///
/// The notification message is a three elements array shown below, packed in MessagePack format.
///
/// [type, method, params]
///
/// type
/// Must be two (integer). Two means that this message is the "Notification" message.
///
/// method
/// A string, which represents the method name.
///
/// params
/// An array of the function arguments. The elements of this array are arbitrary objects.
class Notification extends AbstractResponse {
  const Notification(this.method, this.params);

  /// A string, which represents the method name.
  final String method;

  final List<Object?> params;

  @override
  String toString() => '$method: [${params.join(', ')}]';
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
