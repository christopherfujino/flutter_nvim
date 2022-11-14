import 'event.dart';
export 'event.dart';

import '../nvim.dart' show Notification, NeoVimInterface;
export 'option_set.dart';
import 'redraw_event.dart';
export 'redraw_event.dart';

export 'default_colors_set.dart';
export 'grid_resize.dart';

mixin Events on NeoVimInterface {
  Future<Event> handleNotification(Notification notification) async {
    switch (notification.method) {
      case 'redraw':
        return RedrawEvent(notification);
      default:
        throw UnimplementedError(
          'Unimplemented notification method $notification',
        );
    }
  }
}
