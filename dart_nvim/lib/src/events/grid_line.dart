import 'redraw_event.dart' show RedrawSubEvent;

/// :help ui-event-grid_line
class GridLine extends RedrawSubEvent {
  const GridLine._(this.gridlines);

  final Iterable<GridLineElement> gridlines;

  factory GridLine.fromList(List<Object?> params) {
    return GridLine._(
      params.map<GridLineElement>((Object? line) {
        line as List<Object?>;
        return GridLineElement(
          grid: line[0] as int,
          row: line[1] as int,
          colStart: line[2] as int,
          cells: (line[3] as List<Object?>).cast<List<Object?>>(),
        );
      }),
    );
  }
}

class GridLineElement {
  const GridLineElement({
    required this.grid,
    required this.row,
    required this.colStart,
    required this.cells,
  });

  final int grid;
  final int row;
  final int colStart;
  final List<List<Object?>> cells;
}
