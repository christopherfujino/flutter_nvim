import 'redraw_event.dart' show RedrawSubEvent;

/// Indicates the range of buffer text displayed in the windows.
///
/// ["win_viewport", grid, win, topline, botline, curline, curcol]
/// :help ui.txt /win_viewport/
///
/// Per //third_party/neovim/src/nvim/api/ui_events.in.h, this API is
///
/// void win_viewport(Integer grid, Window win, Integer topline,
///                   Integer botline, Integer curline, Integer curcol,
///                   Integer line_count)
class WinViewport extends RedrawSubEvent {
  const WinViewport._({
    required this.grid,
    required this.win,
    required this.topline,
    required this.botline,
    required this.curline,
    required this.curcol,
    required this.lineCount,
  });

  factory WinViewport.fromList(List<Object?> params) {
    assert(params.length == 1);
    params = params.first as List<Object?>;
    assert(params.length == 7, 'params is $params');
    return WinViewport._(
      grid: params[0] as int,
      win: params[1] as List<int>,
      topline: params[2] as int,
      botline: params[3] as int,
      curline: params[4] as int,
      curcol: params[5] as int,
      lineCount: params[6] as int,
    );
  }

  final int grid;

  // Should this be a more general class?
  final List<int> win;
  final int topline;
  final int botline;
  final int curline;
  final int curcol;
  final int lineCount;

  @override
  String toString() => '''WinViewport(
  grid: $grid,
  win: $win,
  topline: $topline,
  botline: $botline,
  curline: $curline,
  curcol: $curcol,
  lineCount: $lineCount,
)''';
}
