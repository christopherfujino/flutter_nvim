import 'nvim.dart' show Notification, NeoVimInterface;

mixin Events on NeoVimInterface {
  Future<void> handleNotification(Notification notification) async {
    switch (notification.method) {
      case 'redraw':
        // TODO draw
        return;
      default:
        throw UnimplementedError(
          'Unimplemented notification method $notification',
        );
    }
  }
}
