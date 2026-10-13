import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show HtmlParser;

import '../models/conversion_result.dart';

class ParsedHtml {
  ParsedHtml({
    required this.document,
    required this.body,
    required this.styleSheets,
    required this.title,
    required this.parseIssues,
    required this.externalStyleSheets,
    required this.scriptCount,
  });

  final dom.Document document;

  /// The element conversion starts from (`<body>`).
  final dom.Element body;

  /// Text of every `<style>` element in document order.
  final List<String> styleSheets;
  final String title;

  /// Human readable descriptions of recovered syntax errors.
  final List<String> parseIssues;

  /// hrefs of `<link rel="stylesheet">` elements (not fetched).
  final List<String> externalStyleSheets;
  final int scriptCount;
}

class HtmlParserService {
  /// Maximum accepted input size (characters).
  static const maxLength = 2000000;

  /// Parses [html] with the spec-compliant HTML5 parser, which recovers from
  /// malformed markup. Throws [ConversionException] for unusable input.
  ParsedHtml parse(String html) {
    if (html.trim().isEmpty) {
      throw const ConversionException(
        'The HTML input is empty. Paste some HTML or upload a file first.',
      );
    }
    if (html.length > maxLength) {
      throw const ConversionException(
        'The HTML input is too large (over 2 MB). Please use a smaller file.',
      );
    }
    if (!RegExp(r'<[a-zA-Z!]').hasMatch(html)) {
      throw const ConversionException(
        'The input does not look like HTML: no tags were found.',
      );
    }

    final parser = HtmlParser(html, generateSpans: true);
    final dom.Document document;
    try {
      document = parser.parse();
    } catch (e) {
      throw ConversionException('The HTML could not be parsed: $e');
    }

    final issues = <String>[];
    for (final e in parser.errors) {
      // Fragments without a doctype are normal; they are not malformed.
      if (e.errorCode.startsWith('expected-doctype')) continue;
      final line = e.span?.start.line;
      issues.add(
        '${e.errorCode.replaceAll('-', ' ')}'
        '${line == null ? '' : ' (line ${line + 1})'}',
      );
    }

    final styles = [for (final s in document.querySelectorAll('style')) s.text];
    final links = [
      for (final l in document.querySelectorAll('link'))
        if ((l.attributes['rel'] ?? '').toLowerCase().contains('stylesheet'))
          l.attributes['href'] ?? '',
    ];

    final body = document.body ?? document.documentElement;
    if (body == null) {
      throw const ConversionException('The HTML document has no content.');
    }

    return ParsedHtml(
      document: document,
      body: body,
      styleSheets: styles,
      title: document.querySelector('title')?.text.trim() ?? '',
      parseIssues: issues,
      externalStyleSheets: links,
      scriptCount: document.querySelectorAll('script').length,
    );
  }
}
