import 'nvim.dart' show Notification, NeoVimInterface;

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

abstract class Event {}

class RedrawEvent extends Event {
  RedrawEvent(Notification notification) {
    for (final Object? param in notification.params) {
      param as List<Object?>;
      switch (param.first) {
        case 'grid_resize':
          print('grid_resize length is ${param.length}');
          final List<Object?> rest = param[1] as List<Object?>;
          gridResize = GridResize(
            grid: rest[0] as int,
            width: rest[1] as int,
            height: rest[2] as int,
          );
          break;
        case 'option_set':
          //optionSet = OptionSet();
          throw param;
          break;
        default:
          print(param.first);
          if (param.first == 'grid_line') {
            print('len == ${param.length}');
            print('grid: ${param[1]}');
            print('row: ${param[2]}');
            print('colstart: ${param[3]}');
            print('cells: ${param[4]}');
            print('five? ${param[5]}');
            throw 'yay';
          } else {
            throw param.first ?? 'null';
          }
      }
    }
  }

  /// ["grid_resize", grid, width, height]
  ///
  /// Resize a `grid`. If `grid` wasn't seen by the client before, a new grid is
  /// being created with this size.
  late final GridResize? gridResize;
  late final OptionSet? optionSet;
}

class OptionSet {}

class GridResize {
  const GridResize({
    required this.grid,
    required this.width,
    required this.height,
  }) : assert(grid == 1);

  /// Which Grid index.
  ///
  /// Most of these events take a `grid` index as first parameter.  Grid 1 is
  /// the global grid used by default for the entire editor screen state. The
  /// `ext_linegrid` capability by itself will never cause any additional grids
  /// to be created; to enable per-window grids, activate |ui-multigrid|.
  ///
  /// :help ui-linegrid
  final int grid;

  final int width;
  final int height;
}
