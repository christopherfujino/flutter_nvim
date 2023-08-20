import 'dart:async';
import 'dart:io' as io;

import 'package:dart_nvim/dart_nvim.dart';
import 'package:flutter/material.dart';

const Logger logger = Logger();
const nvimPath = String.fromEnvironment('nvim_path');

Future<void> main() async {
  if (nvimPath.isEmpty) {
    throw Exception('You did not provide --dart-define=nvim_path=</path/to/nvim>');
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
  int _notificationCount = 0;
  String _message = '';
  late final NeoVim nvim;
  bool isReady = false;

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
      _notificationCount += 1;
      switch (event.runtimeType) {
        case RedrawEvent:
          return _handleRedraw(event as RedrawEvent);
        default:
          throw UnimplementedError('Yikes! ${event.runtimeType}');
      }
    });

    await nvim.getApiInfo();
    await nvim.uiAttach(500, 500);
  }

  void _handleRedraw(RedrawEvent event) {
    print('updating UI for redraw');
    for (final RedrawSubEvent subEvent in event.subEvents) {
      switch (subEvent.runtimeType) {
        case Flush:
          setState(() {
            _message = 'flush it baby!';
            isReady = true;
          });
          break;
        case GridLine:
          for (final GridLineElement line in (subEvent as GridLine).gridlines) {
            print('${line.cells.length}\t${line.cells}');
          }
          break;
        default:
          print('TODO handle ${subEvent.runtimeType}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return Center(
        child: Column(
          textDirection: TextDirection.ltr,
          children: const <Widget>[
            Text('nvim binary is not yet ready...'),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        textDirection: TextDirection.ltr,
        children: <Widget>[
          Text('You have received $_notificationCount notifications.'),
          Text(
            _message,
          ),
        ],
      ),
    );
  }
}
