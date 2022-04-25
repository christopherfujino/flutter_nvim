import 'dart:io' as io;

import 'lib/interpret.dart';
import 'lib/parse.dart';
import 'lib/scanner.dart';

Future<void> main(List<String> args) async {
  if (args.length != 1) {
    throw Exception('yolo!');
  }

  final path = args.first;
  final io.File sourceFile = io.File(path);
  final String source = await sourceFile.readAsString();
  final List<Token> tokenList = await Scanner(source).scan();
  final Config config = await Parser(tokenList).parse();

  await interpret(config);
}
