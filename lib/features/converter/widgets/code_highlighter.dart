import 'package:flutter/material.dart';

/// Lightweight, regex based syntax highlighting for the editor and the code
/// viewer. Not a parser: it only needs to look right for typical input.
abstract final class Syntax {
  static const keyword = Color(0xFFC792EA);
  static const string = Color(0xFFA5D6A7);
  static const number = Color(0xFFF78C6C);
  static const type = Color(0xFF82AAFF);
  static const param = Color(0xFFFFCB6B);
  static const comment = Color(0xFF5B6478);
  static const tag = Color(0xFFF07178);
  static const attr = Color(0xFFFFCB6B);
  static const punct = Color(0xFF7F8AA3);

  /// Inputs larger than this are shown without highlighting.
  static const maxHighlighted = 150000;
}

final _dart = RegExp(
  r"(//[^\n]*)" // 1 comment
  r"|('(?:\\.|[^'\\\n])*')" // 2 string
  r"|(\b0x[0-9A-Fa-f]+\b|\b\d+(?:\.\d+)?\b)" // 3 number
  r"|(\b(?:import|class|extends|const|return|void|final|super|new|true|false|null|static|late|var|this|required|with|implements|async|await|if|else|in|is|as)\b)" // 4 keyword
  r"|(\b[A-Z_][A-Za-z0-9_]*\b)" // 5 type
  r"|(\b[a-z][A-Za-z0-9_]*(?=:))", // 6 named parameter
);

final _html = RegExp(
  r'(<!--[\s\S]*?(?:-->|$))' // 1 comment
  r'|(</?)([A-Za-z][\w:-]*)' // 2 bracket, 3 tag name
  r'|([\w:@.-]+)(?=\s*=)' // 4 attribute
  r'|("[^"]*"|\x27[^\x27]*\x27)' // 5 string
  r'|(/?>)', // 6 closing bracket
);

List<TextSpan> highlightDart(String code, TextStyle base) {
  if (code.length > Syntax.maxHighlighted) {
    return [TextSpan(text: code, style: base)];
  }
  final spans = <TextSpan>[];
  var last = 0;
  for (final m in _dart.allMatches(code)) {
    if (m.start > last) {
      spans.add(TextSpan(text: code.substring(last, m.start), style: base));
    }
    Color? c;
    if (m.group(1) != null) {
      c = Syntax.comment;
    } else if (m.group(2) != null) {
      c = Syntax.string;
    } else if (m.group(3) != null) {
      c = Syntax.number;
    } else if (m.group(4) != null) {
      c = Syntax.keyword;
    } else if (m.group(5) != null) {
      c = Syntax.type;
    } else {
      c = Syntax.param;
    }
    spans.add(
      TextSpan(
        text: m.group(0),
        style: base.copyWith(color: c),
      ),
    );
    last = m.end;
  }
  if (last < code.length) {
    spans.add(TextSpan(text: code.substring(last), style: base));
  }
  return spans;
}

List<TextSpan> highlightHtml(String code, TextStyle base) {
  if (code.length > Syntax.maxHighlighted) {
    return [TextSpan(text: code, style: base)];
  }
  final spans = <TextSpan>[];
  var last = 0;
  TextSpan colored(String t, Color c) => TextSpan(
    text: t,
    style: base.copyWith(color: c),
  );
  for (final m in _html.allMatches(code)) {
    if (m.start > last) {
      spans.add(TextSpan(text: code.substring(last, m.start), style: base));
    }
    if (m.group(1) != null) {
      spans.add(colored(m.group(1)!, Syntax.comment));
    } else if (m.group(3) != null) {
      spans.add(colored(m.group(2)!, Syntax.punct));
      spans.add(colored(m.group(3)!, Syntax.tag));
    } else if (m.group(4) != null) {
      spans.add(colored(m.group(4)!, Syntax.attr));
    } else if (m.group(5) != null) {
      spans.add(colored(m.group(5)!, Syntax.string));
    } else {
      spans.add(colored(m.group(6)!, Syntax.punct));
    }
    last = m.end;
  }
  if (last < code.length) {
    spans.add(TextSpan(text: code.substring(last), style: base));
  }
  return spans;
}

/// Text controller that paints HTML with syntax colors while editing.
class HtmlHighlightController extends TextEditingController {
  HtmlHighlightController({super.text});

  String? _cachedText;
  TextStyle? _cachedStyle;
  List<TextSpan> _cachedSpans = const [];

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final base = style ?? const TextStyle();
    if (_cachedText != text || _cachedStyle != base) {
      _cachedText = text;
      _cachedStyle = base;
      _cachedSpans = highlightHtml(text, base);
    }
    return TextSpan(style: base, children: _cachedSpans);
  }
}
