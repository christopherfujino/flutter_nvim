import 'dart:io' as io;

import 'scanner.dart';

class Config {}

Future<Config> parse(path) async {
  final io.File sourceFile = io.File(path);
  final String source = await sourceFile.readAsString();
  final List<Token> tokenList = await Scanner(source).scan();
  return await Parser(tokenList).parse();
}

class Parser {
  Parser(this.tokenList);

  final List<Token> tokenList;

  Future<Config> parse() async {
    throw tokenList;
  }
}
