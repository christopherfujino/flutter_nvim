import 'package:dart_nvim/src/events/redraw_event.dart' show RedrawSubEvent;

/// ["option_set", name, value]
///
/// UI-related option changed, where `name` is one of:
///
/// 'arabicshape'
/// 'ambiwidth'
/// 'emoji'
/// 'guifont'
/// 'guifontwide'
/// 'linespace'
/// 'mousefocus'
/// 'pumblend'
/// 'showtabline'
/// 'termguicolors'
/// "ext_*" (all |ui-ext-options|)
class OptionSet implements RedrawSubEvent {
  const OptionSet._({
    required this.arabicshape,
    required this.ambiwidth,
    required this.emoji,
    required this.guifont,
    required this.guifontwide,
    required this.linespace,
    required this.mousefocus,
    required this.pumblend,
    required this.showtabline,
    required this.ttimeout,
    required this.ttimeoutlen,
  });

  factory OptionSet.fromList(List<Object?> params) {
    bool? arabicshape;
    String? ambiwidth;
    bool? emoji;
    String? guifont;
    String? guifontwide;
    int? linespace;
    bool? mousefocus;
    int? pumblend;
    int? showtabline;
    bool? ttimeout;
    int? ttimeoutlen;
    for (final Object? param in params) {
      final String name = (param as List<Object?>)[0] as String;
      switch (name) {
        case 'arabicshape':
          arabicshape = param[1] as bool;
          break;
        case 'ambiwidth':
          final String value = param[1] as String;
          if (!validAmbiwidthValues.contains(value)) {
            throw UnimplementedError(
              'Unknown "ambiwidth" value "$value" returned by nvim!',
            );
          }
          ambiwidth = value;
          break;
        case 'emoji':
          final bool value = param[1] as bool;
          emoji = value;
          break;
        case 'guifont':
          final String value = param[1] as String;
          // what does it mean if this is an empty string?
          guifont = value;
          break;
        case 'guifontwide':
          final String value = param[1] as String;
          guifontwide = value;
          break;
        case 'linespace':
          final int value = param[1] as int;
          linespace = value;
          break;
        case 'mousefocus':
          mousefocus = param[1] as bool;
          break;
        case 'pumblend':
          pumblend = param[1] as int;
          break;
        case 'showtabline':
          final int value = param[1] as int;
          assert(
            value >= 0 && value <= 2,
            'Value $value should be 0, 1, or 2',
          );
          showtabline = value;
          break;
        case 'termguicolors':
          // No-op, since this is related to TUI.
          break;
        case 'ttimeout':
          ttimeout = param[1] as bool;
          break;
        case 'ttimeoutlen':
          ttimeoutlen = param[1] as int;
          break;
        case 'ext_linegrid':
          assert(param[1] == true);
          // For this GUI, we will assume linegrid.
          break;
        case 'ext_multigrid':
          // TODO implement
          assert(param[1] == false);
          break;
        case 'ext_hlstate':
          // The `ext_hlstate` extension allows to the UI to also receive a semantic description of the highlights active in a cell.
          assert(param[1] == false);
          break;
        case 'ext_termcolors':
          assert(param[1] == false);
          break;
        case 'ext_cmdline':
          assert(param[1] == false);
          // TODO implement GUI commandline
          break;
        case 'ext_popupmenu':
          assert(param[1] == false);
          // TODO implement GUI :help popupmenu-completion
          break;
        case 'ext_tabline':
          // prob don't want GUI tabline
          assert(param[1] == false);
          break;
        case 'ext_wildmenu':
          // :help ui-wildmenu
          // deprecated, instead use ui-cmdline with ui-popupmenu
          assert(param[1] == false);
          break;
        case 'ext_messages':
          // TODO implement external messages
          assert(param[1] == false);
          break;
        default:
          throw UnimplementedError(
            'Unimplemented option "$name": ${param[1]}\n$param',
          );
      }
    }
    return OptionSet._(
      arabicshape: arabicshape,
      ambiwidth: ambiwidth,
      emoji: emoji,
      guifont: guifont,
      guifontwide: guifontwide,
      linespace: linespace,
      mousefocus: mousefocus,
      pumblend: pumblend,
      showtabline: showtabline,
      ttimeout: ttimeout,
      ttimeoutlen: ttimeoutlen,
    );
  }

  final bool? arabicshape;
  final String? ambiwidth;
  final bool? emoji;

  /// help: guifont
  ///
  /// TODO: this could be a comma delimitted list.
  /// TODO: GUI should respect this.
  final String? guifont;
  final String? guifontwide;

  /// help: linespace
  ///
  /// Number of pixel lines inserted between characters.
  /// Defaults to 0.
  final int? linespace;

  /// The window that the mouse pointer is on is automatically activated.
  ///
  /// Defaults to off.
  /// TODO implement.
  final bool? mousefocus;

  /// Pseudo transparency for the |popup-menu|.
  ///
  /// 0 is full opaque, 100 fully transparent. 0-30 typically most useful.
  final int? pumblend;

  /// When tab page labels will be displayed.
  ///
  /// This is an enumeration where:
  /// 0: never
  /// 1: only if there are at least two tabs
  /// 2: always
  final int? showtabline;

  /// Whether or not ttimeoutlen should be waited after <Esc> to complete
  /// a key code sequence.
  final bool? ttimeout;

  /// Time in milliseconds to wait for a key code sequence to complete.
  final int? ttimeoutlen;

  // See //third_party/neovim/src/nvim/option.c `p_ambw_values`.
  static const Set<String> validAmbiwidthValues = <String>{
    'single',
    'double',
  };

  @override
  String toString() => '''
arabicshape: $arabicshape
ambiwidth: $ambiwidth
emoji: $emoji
guifont: $guifont
guifontwide: $guifontwide
linespace: $linespace
mousefocus: $mousefocus
pumblend: $pumblend
showtabline: $showtabline
ttimeout: $ttimeout
ttimeoutlen: $ttimeoutlen
''';
}
