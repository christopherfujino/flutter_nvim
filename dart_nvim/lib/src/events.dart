import 'nvim.dart' show Notification, NeoVimInterface;

mixin Events on NeoVimInterface {
  Future<Event> handleNotification(Notification notification) async {
    final Event event;
    switch (notification.method) {
      case 'redraw':
        event = RedrawEvent(notification);
        break;
      default:
        throw UnimplementedError(
          'Unimplemented notification method $notification',
        );
    }
    notificationController.add(event);
    return event;
  }
}

abstract class Event {}

class RedrawEvent extends Event {
  RedrawEvent(Notification notification) {
    for (final Object? param in notification.params) {
      switch ((param as List<Object?>).first) {
        case 'grid_resize':
          final List<Object?> rest = param[1] as List<Object?>;
          gridResize = GridResize(
            grid: rest[0] as int,
            width: rest[1] as int,
            height: rest[2] as int,
          );
          break;
        default:
          // ?
      }
    }
  }

  /// ["grid_resize", grid, width, height]
  ///
  /// Resize a `grid`. If `grid` wasn't seen by the client before, a new grid is
  /// being created with this size.
  late final GridResize gridResize;
}

class GridResize {
  const GridResize({
    required this.grid,
    required this.width,
    required this.height,
  });

  final int grid; // what is this?
  final int width;
  final int height;
}
