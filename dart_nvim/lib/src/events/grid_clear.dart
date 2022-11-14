import 'redraw_event.dart' show RedrawSubEvent;

/// Clear a grid.
///
/// Search "grid_clear" on :help ui.txt
class GridClear implements RedrawSubEvent {
  const GridClear._(this.grid);

  factory GridClear.fromList(List<Object?> params) {
    assert(params.length == 1);
    final List<Object?> gridList = params.first as List<Object?>;
    return GridClear._(gridList.first as int);
  }

  final int grid;
}
