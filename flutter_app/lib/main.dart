import 'dart:async';

import 'package:dart_nvim/dart_nvim.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final attachResponse = await nvim.uiAttach(100, 35);
    print(attachResponse.msgid);
    print('attachResponse.error = ${attachResponse.error}');
    print('attachResponse.result = ${attachResponse.result}');
  }

  void _handleRedraw(RedrawEvent event) {
    logger.printTrace('updating UI for redraw');
    for (final RedrawSubEvent subEvent in event.subEvents) {
      switch (subEvent) {
        case GridResize():
          //subEvent.grid; // TODO handle grid
          _gridWidth = subEvent.width;
          _gridHeight = subEvent.height;
          logger.printTrace('grid_resize: $_gridHeight x $_gridWidth');
        case GridClear():
          _grid = List<List<String>>.generate(
            _gridHeight,
            (int _) => List<String>.generate(
              _gridWidth,
              (int _) => ' ',
              growable: false,
            ),
            growable: false,
          );
          logger.printTrace('grid_clear: $_gridHeight x $_gridWidth');
        case Flush():
          setState(() {
            isReady = true;
          });
          logger.printTrace('flush');
        case GridLine():
          for (final GridLineElement line in subEvent.gridlines) {
            print(
                'row: ${line.row}\tcolStart: ${line.colStart}\t${line.cells}');
            //final grid = line.grid; // TODO handle grid
            int colOffset = line.colStart;
            for (final List<Object?> cell in line.cells) {
              final text = cell[0] as String; // TODO handle hl_id
              int repeat = 1;
              if (cell.length == 3) {
                repeat = cell[2] as int;
              }
              for (int i = 0; i < repeat; i++) {
                _grid[line.row][colOffset] = text;
                colOffset += 1;
              }
            }
          }
        default:
          logger.printError('TODO handle ${subEvent.runtimeType}');
      }
    }
  }

  static final textStyle = GoogleFonts.sourceCodePro(
    fontSize: 12,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return Center(
        child: Column(
          textDirection: TextDirection.ltr,
          children: <Widget>[
            Text(
              'nvim binary is not yet ready...',
              style: textStyle,
            ),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.ltr,
        children: _grid
            .map(
              (List<String> chars) => Text(
                chars.join(''),
                style: textStyle,
              ),
            )
            .toList(),
      ),
    );
  }
}
