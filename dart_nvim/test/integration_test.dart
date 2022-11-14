import 'package:dart_nvim/src/api_calls.dart';
import 'package:dart_nvim/src/common.dart';
import 'package:dart_nvim/src/events/events.dart';
import 'package:dart_nvim/src/nvim.dart';
import 'package:test/test.dart';

void main() {
  late NeoVim nvim;
  setUp(() async {
    nvim = NeoVim(
      logger: BufferLogger(),
      binaryPath: '../third_party/neovim/build/bin/nvim',
    );
  });

  tearDown(() async {
    await nvim.dispose();
  });

  test('getApiInfo()', () async {
    final ApiInfoResponse response = await nvim.getApiInfo();
    expect(response.apiLevel, 9);
    const List<String> requiredFunctions = <String>[
      'nvim_ui_attach',
    ];
    for (final String func in requiredFunctions) {
      expect(response.functions.keys, contains(func));
    }
  });

  test('uiAttach()', () async {
    final Future<Event> futureEvent = nvim.notifications.first;
    const int width = 40;
    const int height = 30;
    final Response response = await nvim.uiAttach(width, height);
    expect(response.error, isNull);
    final Event redraw = await futureEvent;
    expect(redraw, isA<RedrawEvent>());
    final Iterable<RedrawSubEvent> subEvents =
        (redraw as RedrawEvent).subEvents;
    expect(
      subEvents,
      orderedEquals(
        <Object>[
          isA<OptionSet>()
              .having(
                (OptionSet event) => event.arabicshape,
                'arabicshape',
                isTrue,
              )
              .having(
                (OptionSet event) => event.ambiwidth,
                'ambiwidth',
                'single',
              )
              .having(
                (OptionSet event) => event.emoji,
                'emoji',
                isTrue,
              )
              .having(
                (OptionSet event) => event.guifont,
                'guifont',
                isEmpty,
              )
              .having(
                (OptionSet event) => event.guifontwide,
                'guifontwide',
                isEmpty,
              )
              .having(
                (OptionSet event) => event.linespace,
                'linespace',
                0,
              )
              .having(
                (OptionSet event) => event.mousefocus,
                'mousefocus',
                isFalse,
              )
              .having(
                (OptionSet event) => event.pumblend,
                'pumblend',
                0,
              )
              .having(
                (OptionSet event) => event.showtabline,
                'showtabline',
                1,
              )
              .having(
                (OptionSet event) => event.ttimeout,
                'ttimeout',
                isTrue,
              )
              .having(
                (OptionSet event) => event.ttimeoutlen,
                'ttimeoutlen',
                50,
              ),
          isA<DefaultColorsSet>(),
          isA<OptionSet>()
              .having(
                (OptionSet event) => event.arabicshape,
                'arabicshape',
                isNull,
              )
              .having(
                (OptionSet event) => event.ambiwidth,
                'ambiwidth',
                isNull,
              )
              .having(
                (OptionSet event) => event.emoji,
                'emoji',
                isNull,
              )
              .having(
                (OptionSet event) => event.guifont,
                'guifont',
                isNull,
              )
              .having(
                (OptionSet event) => event.guifontwide,
                'guifontwide',
                isNull,
              )
              .having(
                (OptionSet event) => event.linespace,
                'linespace',
                isNull,
              )
              .having(
                (OptionSet event) => event.mousefocus,
                'mousefocus',
                isNull,
              )
              .having(
                (OptionSet event) => event.pumblend,
                'pumblend',
                isNull,
              )
              .having(
                (OptionSet event) => event.showtabline,
                'showtabline',
                isNull,
              )
              .having(
                (OptionSet event) => event.ttimeout,
                'ttimeout',
                isNull,
              )
              .having(
                (OptionSet event) => event.ttimeoutlen,
                'ttimeoutlen',
                isNull,
              ),
          isA<DefaultColorsSet>(),
          isA<GridResize>()
              .having(
                (GridResize event) => event.grid,
                'grid index should be 1', // why?
                1,
              )
              .having(
                (GridResize event) => event.width,
                'width should be what we initialized uiAttach with',
                width,
              )
              .having(
                (GridResize event) => event.height,
                'height should be what we initialized uiAttach with',
                height,
              ),
          Flush.instance,
        ],
      ),
    );
  });
}
