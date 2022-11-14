import 'redraw_event.dart' show RedrawSubEvent;

class GridResize implements RedrawSubEvent {
  const GridResize._({
    required this.grid,
    required this.width,
    required this.height,
  }) : assert(grid == 1);

  factory GridResize.fromList(List<Object?> params) {
    assert(params.length == 1);
    final List<Object?> param = params.first as List<Object?>;
    return GridResize._(
      grid: param[0] as int,
      width: param[1] as int,
      height: param[2] as int,
    );
  }

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

  @override
  String toString() => 'grid: $grid - width: $width - height: $height';
}
