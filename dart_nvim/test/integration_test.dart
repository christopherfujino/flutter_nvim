import 'dart:async';

import 'package:dart_nvim/src/api_calls.dart';
import 'package:dart_nvim/src/nvim.dart';
import 'package:test/test.dart';

void main() {
  late final TestNeoVim nvim;
  setUpAll(() async {
    nvim = TestNeoVim();
    nvim.process = await nvim.futureProcess;
  });

  tearDownAll(() {
    nvim.process.kill();
  });

  test('getApiInfo()', () async {
    final ApiInfoResponse response = await nvim.getApiInfo();
    expect(response.apiLevel, 9);
    expect(response.functions['nvim_ui_attach'], isNotNull);
  });

  test('uiAttach()', () async {
    final Response response = await nvim.uiAttach(500, 500);
    expect(response.error, isNull);
    final Notification notification = await nvim.notifications.first;
    expect(notification.method, 'redraw');
    expect(notification.params, 'foo');
  });
}

class TestNeoVim extends NeoVim {
  final StreamController<Notification> _notificationController = StreamController<Notification>();
  Stream<Notification> get notifications => _notificationController.stream;

  @override
  Future<void> handleNotification(Notification notification) async {
    _notificationController.add(notification);
    return super.handleNotification(notification);
  }
}
