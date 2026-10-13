import 'package:csslib/parser.dart' as css;
import 'package:csslib/visitor.dart';

import 'selector_matcher.dart';

class CssDeclaration {
  const CssDeclaration(this.property, this.value, {this.important = false});
  final String property;
  final String value;
  final bool important;
}

/// A single selector with its declarations (comma lists are split so every
/// selector keeps its own specificity).
class CssRule {
  CssRule({
    required this.selector,
    required this.declarations,
    required this.order,
    required this.origin,
  });

  final CompiledSelector selector;
  final List<CssDeclaration> declarations;

  /// Source order across all style sheets.
  final int order;

  /// 0 = user-agent defaults, 1 = author.
  final int origin;
}

class CssParseResult {
  CssParseResult(this.rules, this.messages, this.ignoredAtRules);
  final List<CssRule> rules;

  /// Parse problems and unsupported selectors.
  final List<String> messages;

  /// `@media`, `@font-face`... directives that were not applied.
  final List<String> ignoredAtRules;
}

class CssParserService {
  /// Parses [source] into flat rules. Never throws; problems are reported in
  /// [CssParseResult.messages].
  CssParseResult parse(String source, {int origin = 1, int startOrder = 0}) {
    final rules = <CssRule>[];
    final messages = <String>[];
    final ignored = <String>[];
    var order = startOrder;

    List<TreeNode> nodes;
    final errors = <css.Message>[];
    try {
      nodes = css.parse(source, errors: errors).topLevels;
    } catch (e) {
      return CssParseResult(rules, ['CSS could not be parsed: $e'], ignored);
    }
    for (final e in errors.take(3)) {
      messages.add('CSS parse problem: ${e.message}');
    }

    for (final node in nodes) {
      if (node is RuleSet) {
        final decls = _declarationsOf(node);
        for (final sel in node.selectorGroup?.selectors ?? const <Selector>[]) {
          final compiled = CompiledSelector.compile(sel);
          if (compiled.unsupportedReason != null) {
            messages.add(
              'Selector "${compiled.text}" skipped: ${compiled.unsupportedReason}',
            );
            continue;
          }
          rules.add(
            CssRule(
              selector: compiled,
              declarations: decls,
              order: order++,
              origin: origin,
            ),
          );
        }
      } else if (node is Directive) {
        final text = node.span.text;
        final head = text.split(RegExp(r'[{;]')).first.trim();
        ignored.add(head.isEmpty ? '@-rule' : head);
      }
    }
    return CssParseResult(rules, messages, ignored);
  }

  List<CssDeclaration> _declarationsOf(RuleSet rule) {
    final out = <CssDeclaration>[];
    for (final d in rule.declarationGroup.declarations) {
      final text = d.span?.text;
      if (text == null) continue;
      final parsed = parseDeclaration(text);
      if (parsed != null) out.add(parsed);
    }
    return out;
  }

  /// Parses the contents of a `style` attribute.
  List<CssDeclaration> parseInlineStyle(String style) {
    final out = <CssDeclaration>[];
    for (final part in _splitDeclarations(style)) {
      final parsed = parseDeclaration(part);
      if (parsed != null) out.add(parsed);
    }
    return out;
  }

  static CssDeclaration? parseDeclaration(String text) {
    final idx = text.indexOf(':');
    if (idx <= 0) return null;
    var prop = text.substring(0, idx).trim();
    var value = text.substring(idx + 1).trim();
    if (value.endsWith(';')) {
      value = value.substring(0, value.length - 1).trim();
    }
    var important = false;
    final imp = RegExp(r'\s*!\s*important\s*$', caseSensitive: false);
    if (imp.hasMatch(value)) {
      important = true;
      value = value.replaceFirst(imp, '').trim();
    }
    if (prop.isEmpty || value.isEmpty) return null;
    if (!prop.startsWith('--')) prop = prop.toLowerCase();
    return CssDeclaration(prop, value, important: important);
  }

  List<String> _splitDeclarations(String s) {
    final parts = <String>[];
    final buf = StringBuffer();
    var depth = 0;
    String? quote;
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      if (quote != null) {
        if (c == quote) quote = null;
      } else if (c == '"' || c == "'") {
        quote = c;
      } else if (c == '(') {
        depth++;
      } else if (c == ')') {
        depth--;
      } else if (c == ';' && depth <= 0) {
        parts.add(buf.toString());
        buf.clear();
        continue;
      }
      buf.write(c);
    }
    if (buf.toString().trim().isNotEmpty) parts.add(buf.toString());
    return parts;
  }
}
