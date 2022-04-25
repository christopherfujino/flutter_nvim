import 'lib/interpret.dart';
import 'lib/parse.dart';

Future<void> main(List<String> args) async {
  if (args.length != 1) {
    throw Exception('yolo!');
  }

  final input = args.first;

  final config = await parse(input);
  await interpret(config);
}
