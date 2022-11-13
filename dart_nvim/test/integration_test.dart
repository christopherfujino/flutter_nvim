import 'package:dart_nvim/src/api_calls.dart';
import 'package:dart_nvim/src/common.dart';
import 'package:dart_nvim/src/events.dart';
import 'package:dart_nvim/src/nvim.dart';
import 'package:test/test.dart';

void main() {
  late NeoVim nvim;
  setUp(() async {
    nvim = NeoVim(
      logger: BufferLogger(),
      binaryPath: '../third_party/neovim/build/bin/nvim',
    );
  });

  tearDown(() async {
    await nvim.dispose();
  });

  test('getApiInfo()', () async {
    final ApiInfoResponse response = await nvim.getApiInfo();
    expect(response.apiLevel, 9);
    expect(response.functions['nvim_ui_attach'], isNotNull);
  });

  test('uiAttach()', () async {
    final Future<Event> futureEvent = nvim.notifications.first;
    final Response response = await nvim.uiAttach(20, 20);
    expect(response.error, isNull);
    final Event redraw = await futureEvent;
    expect(redraw.runtimeType, RedrawEvent);
    expect((redraw as RedrawEvent).gridResize?.width, 20);
    expect(redraw.gridResize?.height, 20);
    expect(redraw.gridResize?.grid, 1);
  });
}
