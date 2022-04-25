enum TokenType {
  // keywords

  /// Keyword "target".
  target,

  // brackets
  openParen,
  closeParen,

  openSquareBracket,
  closeSquareBracket,

  openCurlyBracket,
  closeCurlyBracket,

  // String-like tokens
  identifier,
  stringLiteral,

  // misc
  comma,
  semicolon,
}

class Token {
  Token({
    required this.type,
  });

  final TokenType type;

  String toString() => type.name;
}

class StringToken extends Token {
  StringToken({
    required super.type,
    required this.value,
  });

  final String value;
}

class Scanner {
  Scanner(this.source);

  final String source;
  final List<Token> _tokenList = <Token>[];

  int _index = 0;
  int _line = 1;

  // TODO figure out unicode
  Future<List<Token>> scan() async {
    while (_index < source.length) {
      if (_scanWhitespace()) {
        continue;
      }

      if (_scanKeyword()) {
        continue;
      }

      // handle brackets (parens, square, and curly)
      if (_scanBracket()) {
        continue;
      }

      if (_scanString()) {
        continue;
      }

      // handle named identifiers--must run after [_scanKeyword()],
      // [_scanString()]
      if (_scanIdentifier()) {
        continue;
      }

      if (_scanMisc()) {
        continue;
      }

      _index += 1;
    }
    return _tokenList;
  }

  static const List<String> kKeywords = <String>[
    'target',
  ];

  bool _scanKeyword() {
    // TODO this can be faster
    final String rest = source.substring(_index);
    for (final keyword in kKeywords) {
      if (rest.startsWith(keyword)) {
        _index += keyword.length;
        _tokenList.add(Token(type: TokenType.target));
        return true;
      }
    }
    return false;
  }

  // TODO: handle escapes?
  static final kStringPattern = RegExp(r'"(.*)"');

  bool _scanString() {
    // TODO this can be faster
    final String rest = source.substring(_index);
    final Match? match = kStringPattern.matchAsPrefix(rest);
    if (match != null) {
      // increment index including quotes
      _index += match.group(0)!.length;
      _tokenList.add(
        StringToken(
          type: TokenType.stringLiteral,
          // store the sub-group, excluding quotes
          value: match.group(1)!,
        ),
      );
      return true;
    }
    return false;
  }

  static final kIdentifierPattern = RegExp(r'[a-zA-Z0-9_-]+');

  bool _scanIdentifier() {
    // TODO this can be faster
    final String rest = source.substring(_index);
    final Match? match = kIdentifierPattern.matchAsPrefix(rest);
    if (match != null) {
      final String stringMatch = match.group(0)!;
      _index += stringMatch.length;
      _tokenList.add(
        StringToken(type: TokenType.identifier, value: stringMatch),
      );
      return true;
    }
    return false;
  }

  bool _scanWhitespace() {
    switch (source[_index]) {
      case ' ':
      case '\t':
      case '\n':
      case '\r':
        _index += 1;
        return true;
      default:
        return false;
    }
  }

  bool _scanBracket() {
    switch (source[_index]) {
      case '{':
        _index += 1;
        _tokenList.add(Token(type: TokenType.openCurlyBracket));
        return true;
      case '}':
        _index += 1;
        _tokenList.add(Token(type: TokenType.closeCurlyBracket));
        return true;
      case '[':
        _index += 1;
        _tokenList.add(Token(type: TokenType.openSquareBracket));
        return true;
      case ']':
        _index += 1;
        _tokenList.add(Token(type: TokenType.closeSquareBracket));
        return true;
      case '(':
        _index += 1;
        _tokenList.add(Token(type: TokenType.openParen));
        return true;
      case ')':
        _index += 1;
        _tokenList.add(Token(type: TokenType.closeParen));
        return true;
      default:
        return false;
    }
  }

  bool _scanMisc() {
    switch (source[_index]) {
      case ',':
        _index += 1;
        _tokenList.add(Token(type: TokenType.comma));
        return true;
      case ';':
        _index += 1;
        _tokenList.add(Token(type: TokenType.semicolon));
        return true;
    }

    return false;
  }
}
