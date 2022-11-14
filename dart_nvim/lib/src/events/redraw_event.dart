import 'default_colors_set.dart';
import 'event.dart';
import 'grid_resize.dart';
import 'option_set.dart';
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
          // UI should only draw after a flush event
          // TODO trigger ui flush hook.
          return Flush.instance;
      }
      return null; // TODO throw UnimplementedError()
    });
    return RedrawEvent._(subEvents.whereType<RedrawSubEvent>());
  }

  final Iterable<RedrawSubEvent> subEvents;
}

abstract class RedrawSubEvent {}

class Flush implements RedrawSubEvent {
  const Flush._();

  static const Flush instance = Flush._();
}
