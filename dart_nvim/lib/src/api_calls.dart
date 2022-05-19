import 'nvim.dart';

// This is a mixin for convenience. It is only used in [NeoVim].
mixin ApiCalls on NeoVimInterface {
  /// Call nvim_get_api_info.
  Future<ApiInfoResponse> getApiInfo() async {
    logger.printTrace('about to send request for nvim_get_api_info');
    final Response response =
        await sendRequest('nvim_get_api_info', [], (await process).stdin);
    return ApiInfoResponse(response);
  }

  Future<Response> uiAttach(int width, int height) async {
    const Map<String, Object?> options = <String, Object?>{
      'ext_linegrid': true,
    };
    final Response response = await sendRequest(
      'nvim_ui_attach',
      <Object>[width, height, options],
      (await process).stdin,
    );
    return response;
  }
}

/// Returns a 2-tuple (Array), where item 0 is the current channel id and item
/// 1 is the |api-metadata| map (Dictionary).
class ApiInfoResponse {
  ApiInfoResponse._(
    this.response, {
    required this.majorVersion,
    required this.minorVersion,
    required this.patchVersion,
    required this.apiLevel,
    required this.apiCompatible,
    required this.apiPreRelease,
    required this.functions,
  });

  factory ApiInfoResponse(Response response) {
    final List<Object?> result = response.result as List<Object?>;
    //final int channelId = result[0] as int;
    final Map<Object?, Object?> apiMetadata =
        result[1] as Map<Object?, Object?>;
    final Map<Object?, Object?> version =
        apiMetadata['version'] as Map<Object?, Object?>;
    final Map<String, ApiFunc> functions = {};
    (apiMetadata['functions']! as List<Object?>).forEach((Object? untypedFunc) {
      final Map<Object?, Object?> func = untypedFunc as Map<Object?, Object?>;
      final String name = func['name']! as String;
      functions[name] = ApiFunc(
        method: func['method']! as bool,
        name: name,
        since: func['since']! as int,
        returnType: func['return_type']! as String,
        deprecatedSince: func['deprecated_since'] as int?,
        parameters: func['parameters']! as List<Object?>,
      );
    });
    return ApiInfoResponse._(
      response,
      majorVersion: version['major'] as int,
      minorVersion: version['minor'] as int,
      patchVersion: version['patch'] as int,
      apiLevel: version['api_level'] as int,
      apiCompatible: version['api_compatible'] as int,
      apiPreRelease: version['api_prerelease'] as bool,
      functions: functions,
    );
  }

  final Response response;
  final int majorVersion;
  final int minorVersion;
  final int patchVersion;
  final int apiLevel; // :help api-level
  final int apiCompatible; // API is backwards compatible with this level
  final bool apiPreRelease;
  final Map<String, ApiFunc> functions;

  @override
  String toString() {
    final Iterable<String> funcs =
        functions.entries.where((MapEntry<String, ApiFunc> entry) {
      return entry.value.deprecatedSince != null;
    }).map<String>((MapEntry<String, ApiFunc> entry) {
      return '  ${entry.value}';
    });
    return '''
NeoVim API version: $majorVersion.$minorVersion.$patchVersion
API level: $apiLevel
API compatibility level: $apiCompatible
API pre-release: $apiPreRelease
Functions:
${funcs.join('\n')}
''';
  }
}

class ApiFunc {
  const ApiFunc({
    required this.method,
    required this.name,
    required this.since,
    required this.returnType,
    required this.deprecatedSince,
    required this.parameters,
  });

  final bool method;

  final String name;

  // Since API version
  final int since;

  final int? deprecatedSince;

  final String returnType;

  final List<Object?> parameters;

  @override
  String toString() {
    final Iterable<String> params = parameters.map((Object? paramTuple) {
      final String typeName = (paramTuple as List<Object?>).first! as String;
      final String name = paramTuple[1]! as String;
      return '$name: $typeName';
    });
    final String paramString = '(${params.join(', ')})';
    return '${name.padRight(26)}$paramString -> $returnType';
  }
}
