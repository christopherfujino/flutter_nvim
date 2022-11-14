import 'dart:async';

import 'package:dart_nvim/dart_nvim.dart';
import 'package:flutter/material.dart';

const Logger logger = Logger();

Future<void> main() async {
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
      binaryPath: '../third_party/neovim/build/bin/nvim',
      logger: logger,
    );

    nvim.notifications.listen((Event event) {
      switch (event.runtimeType) {
        case RedrawEvent:
          event as RedrawEvent;
          print('updating UI for redraw');
          setState(() {
            final GridResize resize = event.gridResize;
            _message =
                'grid: ${resize.grid}\nwidth: ${resize.width}\nheight: ${resize.height}';
            _notificationCount += 1;
            isReady = true;
          });
          break;
        default:
          throw UnimplementedError('Yikes! ${event.runtimeType}');
      }
    });

    await nvim.getApiInfo();
    await nvim.uiAttach(500, 500);
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
