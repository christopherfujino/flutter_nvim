import 'event.dart';
export 'event.dart';

import '../nvim.dart' show Notification, NeoVimInterface;
export 'option_set.dart';
import 'redraw_event.dart';
export 'redraw_event.dart';

export 'default_colors_set.dart';
export 'grid_clear.dart';
export 'grid_line.dart';
export 'grid_resize.dart';
export 'win_viewport.dart';

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
