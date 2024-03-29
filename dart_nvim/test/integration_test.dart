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
    final Iterator<RedrawSubEvent> iterator = subEvents.iterator;
    expect(iterator.moveNext(), isTrue);
    expect(
      iterator.current,
      isA<OptionSet>().having(
        (OptionSet event) => event.options,
        'options',
        orderedEquals(<Matcher>[
          isA<ArabicShape>().having(
            (ArabicShape element) => element.value,
            'value',
            isTrue,
          ),
          isA<AmbiWidth>().having(
            (AmbiWidth element) => element.value,
            'value',
            'single',
          ),
          isA<Emoji>().having(
            (Emoji element) => element.value,
            'emoji',
            isTrue,
          ),
          isA<GuiFont>().having(
            (GuiFont element) => element.value,
            'guifont',
            isEmpty,
          ),
          isA<GuiFontWide>().having(
            (GuiFontWide element) => element.value,
            'guifontwide',
            isEmpty,
          ),
          isA<LineSpace>().having(
            (LineSpace element) => element.value,
            'linespace',
            0,
          ),
          isA<MouseFocus>().having(
            (MouseFocus element) => element.value,
            'mousefocus',
            isFalse,
          ),
          isA<PumBlend>().having(
            (PumBlend element) => element.value,
            'pumblend',
            0,
          ),
          isA<ShowTabline>().having(
            (ShowTabline element) => element.value,
            'showtabline',
            1,
          ),
          isA<TTimeout>().having(
            (TTimeout element) => element.value,
            'ttimeout',
            isTrue,
          ),
          isA<TTimeoutLen>().having(
            (TTimeoutLen element) => element.value,
            'ttimeoutlen',
            50,
          ),
        ]),
      ),
    );

    expect(iterator.moveNext(), isTrue);
    expect(
      iterator.current,
      isA<DefaultColorsSet>(),
    );

    expect(iterator.moveNext(), isTrue);
    expect(
      iterator.current,
      isA<OptionSet>().having(
        (OptionSet event) => event.options,
        'options',
        isEmpty,
      ),
    );

    expect(iterator.moveNext(), isTrue);
    expect(
      iterator.current,
      isA<DefaultColorsSet>(),
    );

    expect(iterator.moveNext(), isTrue);
    expect(
      iterator.current,
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
    );

    expect(iterator.moveNext(), isTrue);
    expect(
      iterator.current,
      isA<GridClear>().having(
        (GridClear event) => event.grid,
        'grid',
        equals(1),
      ),
    );

    expect(iterator.moveNext(), isTrue);
    expect(
      iterator.current,
      isA<WinViewport>()
          .having(
            (WinViewport event) => event.grid,
            'grid',
            equals(2), // how many grids do we have?
          )
          .having(
            (WinViewport event) => event.win,
            'win',
            // huh?
            containsAllInOrder(const <int>[205, 3, 232]),
          ),
    );

    expect(iterator.moveNext(), isTrue);
    expect(
      iterator.current,
      isA<GridLine>(), // TODO need to assert on the individual lines
    );

    expect(iterator.moveNext(), isTrue);
    expect(
      iterator.current,
      isA<WinViewport>().having(
        (WinViewport event) => event.grid,
        'grid',
        equals(2), // how many grids do we have?
      ),
    );

    expect(iterator.moveNext(), isTrue);
    expect(
      iterator.current,
      equals(Flush.instance),
    );

    expect(iterator.moveNext(), isFalse);
  });
}
