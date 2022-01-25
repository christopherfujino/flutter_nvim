import 'nvim.dart';

// This is a mixin for convenience. It is only used in [NeoVim].
mixin ApiCalls on NeoVimInterface {
  /// Call nvim_get_api_info.
  Future<ApiInfoResponse> getApiInfo() async {
    print('about to send request for nvim_get_api_info');
    final Response response = await sendRequest('nvim_get_api_info', [], process.stdin);
    return ApiInfoResponse(response);
  }

  Future<Response> uiAttach(int width, int height) async {
    print('about to send request for nvim_ui_attach');
    final Response response = await sendRequest(
      'nvim_ui_attach',
      [width, height, {}],
      process.stdin,
    );
    print('received response from server');
    return response;
  }
}

/// Returns a 2-tuple (Array), where item 0 is the current channel id and item
/// 1 is the |api-metadata| map (Dictionary).
class ApiInfoResponse {
  ApiInfoResponse._(this.response, {
    required this.majorVersion,
    required this.minorVersion,
    required this.patchVersion,
    required this.apiLevel,
    required this.apiCompatible,
    required this.apiPreRelease,
  });

  factory ApiInfoResponse(Response response) {
    final result = response.result as List<Object?>;
    //final int channelId = result[0] as int;
    final Map<Object?, Object?> apiMetadata = result[1] as Map<Object?, Object?>;
    final Map<Object?, Object?> version = apiMetadata['version'] as Map<Object?, Object?>;
    return ApiInfoResponse._(
      response,
      majorVersion: version['major'] as int,
      minorVersion: version['minor'] as int,
      patchVersion: version['patch'] as int,
      apiLevel: version['api_level'] as int,
      apiCompatible: version['api_compatible'] as int,
      apiPreRelease: version['api_prerelease'] as bool,
    );
  }

  final Response response;
  final int majorVersion;
  final int minorVersion;
  final int patchVersion;
  final int apiLevel; // :help api-level
  final int apiCompatible; // API is backwards compatible with this level
  final bool apiPreRelease;

  @override
  String toString() {
    return '''
NeoVim API version: $majorVersion.$minorVersion.$patchVersion
API level: $apiLevel
API compatibility level: $apiCompatible
API pre-release: $apiPreRelease
''';
  }
}
