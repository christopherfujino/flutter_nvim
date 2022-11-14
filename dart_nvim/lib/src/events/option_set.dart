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
  const OptionSet._(this.options);

  final Iterable<OptionSetElement> options;

  factory OptionSet.fromList(List<Object?> params) {
    final Iterable<OptionSetElement?> options =
        params.map<OptionSetElement?>((Object? param) {
      final String name = (param as List<Object?>)[0] as String;
      switch (name) {
        case 'arabicshape':
          return ArabicShape(param[1] as bool);
        case 'ambiwidth':
          return AmbiWidth(param[1] as String);
        case 'emoji':
          return Emoji(param[1] as bool);
        case 'guifont':
          // what does it mean if this is an empty string?
          return GuiFont(param[1] as String);
        case 'guifontwide':
          return GuiFontWide(param[1] as String);
        case 'linespace':
          return LineSpace(param[1] as int);
        case 'mousefocus':
          return MouseFocus(param[1] as bool);
        case 'pumblend':
          return PumBlend(param[1] as int);
        case 'showtabline':
          return ShowTabline(param[1] as int);
        case 'termguicolors':
          // No-op, since this is related to TUI.
          return null;
        case 'ttimeout':
          return TTimeout(param[1] as bool);
        case 'ttimeoutlen':
          return TTimeoutLen(param[1] as int);
        case 'ext_linegrid':
          assert(param[1] == true);
          return null;
        case 'ext_multigrid':
          // TODO implement
          assert(param[1] == false);
          return null;
        case 'ext_hlstate':
          // The `ext_hlstate` extension allows to the UI to also receive a semantic description of the highlights active in a cell.
          assert(param[1] == false);
          return null;
        case 'ext_termcolors':
          assert(param[1] == false);
          return null;
        case 'ext_cmdline':
          assert(param[1] == false);
          // TODO implement GUI commandline
          return null;
        case 'ext_popupmenu':
          assert(param[1] == false);
          // TODO implement GUI :help popupmenu-completion
          return null;
        case 'ext_tabline':
          // prob don't want GUI tabline
          assert(param[1] == false);
          return null;
        case 'ext_wildmenu':
          // :help ui-wildmenu
          // deprecated, instead use ui-cmdline with ui-popupmenu
          assert(param[1] == false);
          return null;
        case 'ext_messages':
          // TODO implement external messages
          assert(param[1] == false);
          return null;
        default:
          throw UnimplementedError(
            'Unimplemented option "$name": ${param[1]}\n$param',
          );
      }
    });
    return OptionSet._(options.whereType<OptionSetElement>());
  }
}

abstract class OptionSetElement<T> {
  const OptionSetElement(this.value);

  final T value;
}

class ArabicShape extends OptionSetElement<bool> {
  const ArabicShape._(super.value) : super();

  factory ArabicShape(bool value) => value ? _true : _false;

  static const ArabicShape _true = ArabicShape._(true);
  static const ArabicShape _false = ArabicShape._(false);
}

// See //third_party/neovim/src/nvim/option.c `p_ambw_values`.
class AmbiWidth extends OptionSetElement<String> {
  const AmbiWidth(super.value) : assert(value == 'single' || value == 'double');
}

class Emoji extends OptionSetElement<bool> {
  const Emoji._(super.value) : super();

  factory Emoji(bool value) => value ? _true : _false;

  static const Emoji _true = Emoji._(true);
  static const Emoji _false = Emoji._(false);
}

/// help: guifont
///
/// TODO: this could be a comma delimitted list.
/// TODO: GUI should respect this.
class GuiFont extends OptionSetElement<String> {
  const GuiFont(super.value);
}

class GuiFontWide extends OptionSetElement<String> {
  const GuiFontWide(super.value);
}

/// Number of pixel lines inserted between characters.
///
/// Defaults to 0.
/// help: linespace
class LineSpace extends OptionSetElement<int> {
  const LineSpace(super.value);
}

/// The window that the mouse pointer is on is automatically activated.
///
/// Defaults to off.
/// TODO implement.
class MouseFocus extends OptionSetElement<bool> {
  const MouseFocus(super.value);
}

/// Pseudo transparency for the |popup-menu|.
///
/// 0 is full opaque, 100 fully transparent. 0-30 typically most useful.
class PumBlend extends OptionSetElement<int> {
  const PumBlend(super.value);
}

/// When tab page labels will be displayed.
///
/// This is an enumeration where:
/// 0: never
/// 1: only if there are at least two tabs
/// 2: always
class ShowTabline extends OptionSetElement<int> {
  const ShowTabline(super.value) : assert(value >= 0 && value <= 2);
}

/// Whether or not ttimeoutlen should be waited after <Esc> to complete
/// a key code sequence.
class TTimeout extends OptionSetElement<bool> {
  const TTimeout(super.value);
}

/// Time in milliseconds to wait for a key code sequence to complete.
class TTimeoutLen extends OptionSetElement<int> {
  const TTimeoutLen(super.value);
}
