import 'default_colors_set.dart';
import 'event.dart';
import 'grid_clear.dart';
import 'grid_line.dart';
import 'grid_resize.dart';
import 'option_set.dart';
import 'win_viewport.dart';
import '../nvim.dart' show Notification;

class RedrawEvent extends Event {
  const RedrawEvent._(this.subEvents);

  factory RedrawEvent(Notification notification) {
    // make this non-nullable when everything is implemented
    final Iterable<RedrawSubEvent?> subEvents = notification.params.map<RedrawSubEvent?>((Object? param) {
      final String head = (param as List<Object?>).first as String;
      final List<Object?> tail = param.sublist(1);
      switch (head) {
        case 'grid_resize':
          return GridResize.fromList(tail);
        case 'option_set':
          return OptionSet.fromList(tail);
        case 'default_colors_set':
          return DefaultColorsSet.fromList(tail);
        case 'flush':
          return Flush.instance;
        case 'hl_attr_define':
          // TODO implement for highlights
          return null;
        case 'hl_group_set':
          // The builtin highlight group `name` was set to use the attributes `hl_id`
          // defined by a previous `hl_attr_define` call. This event is not needed
          // to render the grids which use attribute ids directly, but is useful
          // for an UI who want to render its own elements with consistent
          // highlighting. For instance an UI using |ui-popupmenu| events, might
          // use the |hl-Pmenu| family of builtin highlights.
          return null;
        case 'grid_clear':
          return GridClear.fromList(tail);
        case 'win_viewport':
          return WinViewport.fromList(tail);
        case 'grid_line':
          return GridLine.fromList(tail);
        case 'grid_cursor_goto':
          // TODO implement cursor
          return null;
        case 'mode_info_set':
          // ["mode_info_set", cursor_style_enabled, mode_info]
          //print('cursor_style_enabled: ${(tail[0] as List<Object?>)[0]}');
          //((tail[0] as List<Object?>)[1] as List).forEach(print);
          // TODO implement cursor style
          // TODO mode_info here seems important
          return null;
        case 'mode_change':
          // ["mode_change", mode, mode_idx]
          // TODO implement modes
          return null;
        case 'mouse_off':
        case 'mouse_on':
          // TODO implement mouse
          return null;
      }
      throw UnimplementedError('TODO implement $head redraw subevent');
    });
    return RedrawEvent._(subEvents.whereType<RedrawSubEvent>());
  }

  final Iterable<RedrawSubEvent> subEvents;
}

abstract class RedrawSubEvent {
  const RedrawSubEvent();
}

class Flush implements RedrawSubEvent {
  const Flush._();

  static const Flush instance = Flush._();
}
