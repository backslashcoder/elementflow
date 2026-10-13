import 'package:csslib/visitor.dart';
import 'package:csslib/parser.dart' show TokenKind;
import 'package:html/dom.dart' as dom;

class _Compound {
  _Compound(this.combinator);

  /// Relation to the previous compound (descendant, child, ...).
  final int combinator;
  final List<SimpleSelector> parts = [];
}

/// A selector pre-processed for matching against `package:html` elements.
class CompiledSelector {
  CompiledSelector._(
    this.text,
    this._compounds,
    this.specificity,
    this.unsupportedReason,
  );

  final String text;
  final List<_Compound> _compounds;
  final int specificity;

  /// Non-null when the selector can never match in a static conversion
  /// (pseudo-elements, hover states...).
  final String? unsupportedReason;

  static const _staticStates = {
    'hover',
    'focus',
    'active',
    'visited',
    'focus-within',
    'focus-visible',
    'disabled',
    'checked',
    'target',
    'placeholder-shown',
  };

  static CompiledSelector compile(Selector selector) {
    final compounds = <_Compound>[];
    var ids = 0, classes = 0, types = 0;
    String? unsupported;
    for (final seq in selector.simpleSelectorSequences) {
      final s = seq.simpleSelector;
      if (compounds.isEmpty || !seq.isCombinatorNone) {
        compounds.add(
          _Compound(
            compounds.isEmpty ? TokenKind.COMBINATOR_NONE : seq.combinator,
          ),
        );
      }
      compounds.last.parts.add(s);
      final inner = s is NamespaceSelector ? s.nameAsSimpleSelector : s;
      if (inner is IdSelector) {
        ids++;
      } else if (inner is ClassSelector || inner is AttributeSelector) {
        classes++;
      } else if (inner is PseudoElementSelector) {
        unsupported = 'pseudo-element ::${inner.name} is not supported';
        types++;
      } else if (inner is PseudoClassSelector) {
        if (_staticStates.contains(inner.name)) {
          unsupported = ':${inner.name} is an interactive state';
        }
        classes++;
      } else if (inner is ElementSelector && !inner.isWildcard) {
        types++;
      }
    }
    return CompiledSelector._(
      selector.span?.text.trim() ?? '',
      compounds,
      ids * 10000 + classes * 100 + types,
      unsupported,
    );
  }

  bool matches(dom.Element el) {
    if (unsupportedReason != null || _compounds.isEmpty) return false;
    return _matchFrom(_compounds.length - 1, el);
  }

  bool _matchFrom(int index, dom.Element el) {
    final compound = _compounds[index];
    for (final part in compound.parts) {
      if (!_matchSimple(part, el)) return false;
    }
    if (index == 0) return true;
    final c = compound.combinator;
    if (c == TokenKind.COMBINATOR_GREATER) {
      final p = el.parent;
      return p != null && _matchFrom(index - 1, p);
    }
    if (c == TokenKind.COMBINATOR_PLUS) {
      final p = el.previousElementSibling;
      return p != null && _matchFrom(index - 1, p);
    }
    if (c == TokenKind.COMBINATOR_TILDE) {
      var p = el.previousElementSibling;
      while (p != null) {
        if (_matchFrom(index - 1, p)) return true;
        p = p.previousElementSibling;
      }
      return false;
    }
    var p = el.parent;
    while (p != null) {
      if (_matchFrom(index - 1, p)) return true;
      p = p.parent;
    }
    return false;
  }

  static bool _matchSimple(SimpleSelector s, dom.Element el) {
    if (s is NamespaceSelector) {
      final inner = s.nameAsSimpleSelector;
      return inner == null || _matchSimple(inner, el);
    }
    if (s is ElementSelector) {
      return s.isWildcard || s.name.toLowerCase() == el.localName;
    }
    if (s is IdSelector) return el.id == s.name;
    if (s is ClassSelector) return el.classes.contains(s.name);
    if (s is AttributeSelector) return _matchAttribute(s, el);
    if (s is NegationSelector) {
      final arg = s.negationArg;
      return arg == null || !_matchSimple(arg, el);
    }
    if (s is PseudoClassSelector) return _matchPseudo(s, el);
    return false;
  }

  static bool _matchAttribute(AttributeSelector s, dom.Element el) {
    final actual = el.attributes[s.name];
    if (actual == null) return false;
    final op = s.matchOperator();
    if (op == null || op.isEmpty) return true;
    var expected = s.valueToString();
    if (expected.startsWith('"') && expected.endsWith('"')) {
      expected = expected.substring(1, expected.length - 1);
    }
    switch (op) {
      case '=':
        return actual == expected;
      case '~=':
        return actual.split(RegExp(r'\s+')).contains(expected);
      case '|=':
        return actual == expected || actual.startsWith('$expected-');
      case '^=':
        return expected.isNotEmpty && actual.startsWith(expected);
      case r'$=':
        return expected.isNotEmpty && actual.endsWith(expected);
      case '*=':
        return expected.isNotEmpty && actual.contains(expected);
    }
    return false;
  }

  static List<dom.Element> _siblings(dom.Element el) =>
      el.parent?.children.toList() ?? [el];

  static bool _matchPseudo(PseudoClassSelector s, dom.Element el) {
    switch (s.name) {
      case 'root':
        return el.localName == 'html';
      case 'first-child':
        return _siblings(el).first == el;
      case 'last-child':
        return _siblings(el).last == el;
      case 'only-child':
        return _siblings(el).length == 1;
      case 'first-of-type':
        return _siblings(el).firstWhere((e) => e.localName == el.localName) ==
            el;
      case 'last-of-type':
        return _siblings(el).lastWhere((e) => e.localName == el.localName) ==
            el;
      case 'empty':
        return el.nodes.isEmpty;
      case 'link':
        return el.localName == 'a' && el.attributes.containsKey('href');
      case 'nth-child':
      case 'nth-last-child':
      case 'nth-of-type':
        final text = s.span?.text ?? '';
        final m = RegExp(r'\((.*)\)').firstMatch(text);
        if (m == null) return false;
        var sibs = _siblings(el);
        if (s.name == 'nth-of-type') {
          sibs = sibs.where((e) => e.localName == el.localName).toList();
        }
        var pos = sibs.indexOf(el) + 1;
        if (s.name == 'nth-last-child') pos = sibs.length - pos + 1;
        return _nthMatches(m.group(1)!.trim().toLowerCase(), pos);
    }
    return false;
  }

  static bool _nthMatches(String expr, int pos) {
    if (expr == 'odd') return pos.isOdd;
    if (expr == 'even') return pos.isEven;
    final plain = int.tryParse(expr);
    if (plain != null) return pos == plain;
    final m = RegExp(r'^([+-]?\d*)n\s*(?:([+-])\s*(\d+))?$').firstMatch(expr);
    if (m == null) return false;
    final aText = m.group(1)!;
    final a = aText.isEmpty || aText == '+'
        ? 1
        : aText == '-'
        ? -1
        : int.parse(aText);
    final b = m.group(3) == null
        ? 0
        : (m.group(2) == '-' ? -1 : 1) * int.parse(m.group(3)!);
    if (a == 0) return pos == b;
    final n = (pos - b) / a;
    return n >= 0 && n == n.truncate();
  }
}
