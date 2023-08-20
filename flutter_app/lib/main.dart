import 'dart:async';
import 'dart:io' as io;

import 'package:dart_nvim/dart_nvim.dart';
import 'package:flutter/material.dart';

const Logger logger = Logger();
const nvimPath = String.fromEnvironment('nvim_path');

Future<void> main() async {
  if (nvimPath.isEmpty) {
    throw Exception(
      'You did not provide --dart-define=nvim_path=</path/to/nvim>',
    );
  }
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const Directionality(
      textDirection: TextDirection.ltr,
      child: EditorWidget(),
    ),
  );
}

class EditorWidget extends StatefulWidget {
  const EditorWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<EditorWidget> createState() => _EditorWidgetState();
}

class _EditorWidgetState extends State<EditorWidget> {
  _EditorWidgetState();
  late final NeoVim nvim;
  bool isReady = false;
  List<List<String>> _grid = <List<String>>[];
  late int _gridWidth;
  late int _gridHeight;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  Future<void> _initialize() async {
    nvim = NeoVim(
      binaryPath: nvimPath,
      logger: logger,
    );

    nvim.notifications.listen((Event event) {
      switch (event.runtimeType) {
        case RedrawEvent:
          return _handleRedraw(event as RedrawEvent);
        default:
          throw UnimplementedError('Yikes! ${event.runtimeType}');
      }
    });

    await nvim.getApiInfo();
    await nvim.uiAttach(200, 50);
  }

  void _handleRedraw(RedrawEvent event) {
    logger.printTrace('updating UI for redraw');
    for (final RedrawSubEvent subEvent in event.subEvents) {
      switch (subEvent) {
        case GridResize():
          //subEvent.grid; // TODO handle grid
          _gridWidth = subEvent.width;
          _gridHeight = subEvent.height;
          print('grid_resize: $_gridHeight x $_gridWidth');
        case GridClear():
          _grid = List<List<String>>.generate(
            _gridHeight,
            (int _) => List<String>.generate(
              _gridWidth,
              (int _) => 'x',
              growable: false,
            ),
            growable: false,
          );
          print('grid_clear: $_gridHeight x $_gridWidth');
        case Flush():
          setState(() {
            isReady = true;
          });
          print('flush');
        case GridLine():
          for (final GridLineElement line in subEvent.gridlines) {
            print('row: ${line.row}\tcolStart: ${line.colStart}\t${line.cells}');
            //final grid = line.grid; // TODO handle grid
            int colOffset = line.colStart;
            for (final List<Object?> cell in line.cells) {
              final text = cell[0] as String; // TODO handle hl_id
              int repeat = 1;
              if (cell.length == 3) {
                repeat = cell[2] as int;
              }
              for (int i = 0; i < repeat; i++) {
                try {
                  _grid[line.row][colOffset] = text;
                  //_grid[line.row][i] = text;
                } on RangeError {
                  print('cell = $cell');
                  rethrow;
                }
                colOffset += 1;
              }
            }
          }
        default:
          print('TODO handle ${subEvent.runtimeType}');
      }
      //switch (subEvent.runtimeType) {
      //  case Flush:
      //    setState(() {
      //      _message = 'flush it baby!';
      //      isReady = true;
      //    });
      //    break;
      //  case GridLine:
      //    for (final GridLineElement line in (subEvent as GridLine).gridlines) {
      //      print('${line.cells.length}\t${line.cells}');
      //    }
      //    break;
      //  default:
      //    print('TODO handle ${subEvent.runtimeType}');
      //}
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return const Center(
        child: Column(
          textDirection: TextDirection.ltr,
          children: <Widget>[
            Text('nvim binary is not yet ready...'),
          ],
        ),
      );
    }
    for (final row in _grid) {
      io.stdout.writeln(row.join(''));
    }
    return Center(
      child: Column(
        textDirection: TextDirection.ltr,
        children:
            _grid.map((List<String> chars) => Text(chars.join(''))).toList(),
            //_grid.map((List<String> chars) => Text(chars.join(''))).toList(),
            //const <Widget>[
            //  Text('abcd'),
            //  Text('1234'),
            //],
      ),
    );
  }
}
