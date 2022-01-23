import 'nvim.dart';

// This is a mixin for convenience. It is only used in [NeoVim].
mixin ApiCalls on NeoVimInterface {
  /// Call nvim_get_api_info.
  Future<Response> getApiInfo() async {
    return sendRequest('nvim_get_api_info', [], process.stdin);
  }
}
