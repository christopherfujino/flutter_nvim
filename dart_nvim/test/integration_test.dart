import 'package:dart_nvim/src/api_calls.dart';
import 'package:dart_nvim/src/common.dart';
import 'package:dart_nvim/src/events.dart';
import 'package:dart_nvim/src/nvim.dart';
import 'package:test/test.dart';

void main() {
  late final NeoVim nvim;
  setUpAll(() async {
    nvim = NeoVim(logger: BufferLogger());
  });

  tearDownAll(() {
    nvim.dispose();
  });

  test('getApiInfo()', () async {
    final ApiInfoResponse response = await nvim.getApiInfo();
    expect(response.apiLevel, 9);
    expect(response.functions['nvim_ui_attach'], isNotNull);
  });

  test('uiAttach()', () async {
    final Response response = await nvim.uiAttach(500, 500);
    expect(response.error, isNull);
    final Event redraw = await nvim.notifications.first;
    expect(redraw.runtimeType, RedrawEvent);
    expect((redraw as RedrawEvent).gridResize.width, 500);
    expect(redraw.gridResize.height, 500);
    expect(redraw.gridResize.grid, 1);
  });
}
