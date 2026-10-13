import 'dart:math' as math;

import 'package:html/dom.dart' as dom;

import '../models/conversion_result.dart';
import 'css_parser_service.dart';
import 'css_shorthand.dart';
import 'css_values.dart';
import 'warning_collector.dart';

/// Minimal user-agent style sheet. Parsed with the same CSS parser as author
/// styles and applied with the lowest priority.
const uaStylesheet = '''
html, body, div, section, article, aside, main, header, footer, nav, address,
blockquote, center, dd, dl, dt, fieldset, figcaption, figure, form, h1, h2, h3,
h4, h5, h6, hgroup, hr, p, pre, details, summary, legend, ul, ol, menu, dir,
optgroup, option, caption { display: block; }
li { display: list-item; }
table { display: table; }
thead, tbody, tfoot { display: table-row-group; }
tr { display: table-row; }
td, th { display: table-cell; }
img, input, button, select, textarea, video, audio, canvas, svg, iframe,
object, embed, meter, progress { display: inline-block; }
head, script, style, title, meta, link, template, noscript, datalist, area,
base, param, source, track, [hidden] { display: none; }

body { margin: 8px; }
h1 { font-size: 2em; margin: 0.67em 0; font-weight: bold; }
h2 { font-size: 1.5em; margin: 0.83em 0; font-weight: bold; }
h3 { font-size: 1.17em; margin: 1em 0; font-weight: bold; }
h4 { margin: 1.33em 0; font-weight: bold; }
h5 { font-size: 0.83em; margin: 1.67em 0; font-weight: bold; }
h6 { font-size: 0.67em; margin: 2.33em 0; font-weight: bold; }
p, dl, menu { margin: 1em 0; }
blockquote, figure { margin: 1em 40px; }
dd { margin-left: 40px; }
ul, ol { margin: 1em 0; padding-left: 40px; }
ul { list-style-type: disc; }
ol { list-style-type: decimal; }
ul ul, ul ol, ol ul, ol ol { margin: 0; }
ul ul { list-style-type: circle; }
pre { font-family: monospace; white-space: pre; margin: 1em 0; }
code, kbd, samp, tt { font-family: monospace; }
b, strong, th { font-weight: bold; }
th { text-align: center; }
i, em, cite, var, dfn, address { font-style: italic; }
u, ins { text-decoration: underline; }
s, strike, del { text-decoration: line-through; }
small, sub, sup { font-size: 0.83em; }
big { font-size: 1.17em; }
mark { background-color: #ffff00; color: #000000; }
a[href] { color: #0000ee; text-decoration: underline; }
center { text-align: center; }
hr { margin: 0.5em 0; border: 1px solid #9e9e9e; }
fieldset { margin: 0 2px; padding: 0.35em 0.75em 0.625em; border: 1px solid #c0c0c0; }
legend { padding: 0 2px; }
td, th { padding: 1px; }
input, textarea, select, button { font-size: 13.3333px; }
input, textarea { width: 170px; background-color: #ffffff; border: 1px solid #767676; padding: 1px 2px; }
select { width: 150px; background-color: #ffffff; border: 1px solid #767676; }
button, input[type="submit"], input[type="button"], input[type="reset"] {
  width: auto; background-color: #efefef; border: 1px solid #767676;
  border-radius: 3px; padding: 1px 6px; }
''';

/// Longhand properties the converter reads.
const supportedProperties = <String>{
  'display',
  'position',
  'float',
  'width',
  'height',
  'min-width',
  'max-width',
  'min-height',
  'max-height',
  'margin-top',
  'margin-right',
  'margin-bottom',
  'margin-left',
  'padding-top',
  'padding-right',
  'padding-bottom',
  'padding-left',
  'color',
  'background-color',
  'background-image',
  'opacity',
  'box-shadow',
  'border-top-width',
  'border-right-width',
  'border-bottom-width',
  'border-left-width',
  'border-top-style',
  'border-right-style',
  'border-bottom-style',
  'border-left-style',
  'border-top-color',
  'border-right-color',
  'border-bottom-color',
  'border-left-color',
  'border-top-left-radius',
  'border-top-right-radius',
  'border-bottom-right-radius',
  'border-bottom-left-radius',
  'font-size',
  'font-weight',
  'font-family',
  'font-style',
  'line-height',
  'letter-spacing',
  'text-align',
  'text-decoration-line',
  'text-transform',
  'white-space',
  'text-overflow',
  'list-style-type',
  'visibility',
  'flex-direction',
  'flex-wrap',
  'justify-content',
  'align-items',
  'align-self',
  'flex-grow',
  'flex-shrink',
  'flex-basis',
  'row-gap',
  'column-gap',
  'overflow-x',
  'overflow-y',
  'object-fit',
  'box-sizing',
  'grid-template-columns',
  'border-collapse',
};

/// Properties with no visual meaning in a static conversion; reported as
/// informational notes rather than warnings.
const _infoOnlyProperties = <String>{
  'cursor',
  'transition',
  'transition-property',
  'transition-duration',
  'transition-timing-function',
  'transition-delay',
  'animation',
  'animation-name',
  'animation-duration',
  'animation-delay',
  'animation-iteration-count',
  'animation-timing-function',
  'will-change',
  'user-select',
  'pointer-events',
  'z-index',
  'scroll-behavior',
  'appearance',
  'caret-color',
  'resize',
  'tab-size',
  'text-rendering',
  'accent-color',
  'touch-action',
  'font-variant',
  'font-feature-settings',
  'font-display',
  'quotes',
  'orphans',
  'widows',
  'isolation',
  'outline',
  'outline-offset',
  'outline-width',
  'outline-style',
  'outline-color',
  'text-size-adjust',
  'word-break',
  'overflow-wrap',
  'word-wrap',
  'hyphens',
  'border-spacing',
  'border-image',
  'list-style-position',
  'vertical-align',
  'table-layout',
  'empty-cells',
  'speak',
  'content',
  'counter-reset',
  'counter-increment',
};

const _inheritedProperties = <String>{
  'color',
  'font-family',
  'font-size',
  'font-style',
  'font-weight',
  'line-height',
  'letter-spacing',
  'text-align',
  'text-decoration-line',
  'text-transform',
  'white-space',
  'list-style-type',
  'visibility',
  'cursor',
};

class ComputedStyle {
  ComputedStyle(this.props, this.custom, this.fontSize, this.color);

  /// Cascaded longhand values (strings), after inheritance.
  final Map<String, String> props;

  /// Inherited CSS custom properties (`--name`).
  final Map<String, String> custom;

  /// Computed font size in px.
  final double fontSize;

  /// Computed text color (ARGB).
  final int color;

  String? operator [](String name) => props[name];

  String get display => props['display'] ?? 'inline';

  static ComputedStyle root() => ComputedStyle({}, {}, 16, 0xFF000000);
}

class _Entry {
  _Entry(this.decl, this.origin, this.specificity, this.order, this.index);
  final CssDeclaration decl;
  final int origin, specificity, order, index;

  int compareTo(_Entry o) {
    final a = decl.important ? 1 : 0, b = o.decl.important ? 1 : 0;
    if (a != b) return a - b;
    if (origin != o.origin) return origin - o.origin;
    if (specificity != o.specificity) return specificity - o.specificity;
    if (order != o.order) return order - o.order;
    return index - o.index;
  }
}

/// Resolves the cascade (UA, author, inline), shorthand expansion,
/// `var()` substitution and inheritance for elements.
class StyleResolver {
  StyleResolver(this.rules, this._parser, this._warnings);

  final List<CssRule> rules;
  final CssParserService _parser;
  final WarningCollector _warnings;

  ComputedStyle compute(
    dom.Element el,
    ComputedStyle parent, {
    List<CssDeclaration> hints = const [],
  }) {
    final entries = <_Entry>[];
    for (final rule in rules) {
      if (!rule.selector.matches(el)) continue;
      for (var i = 0; i < rule.declarations.length; i++) {
        entries.add(
          _Entry(
            rule.declarations[i],
            rule.origin,
            rule.selector.specificity,
            rule.order,
            i,
          ),
        );
      }
    }
    for (var i = 0; i < hints.length; i++) {
      entries.add(_Entry(hints[i], 0, 1, 1 << 30, i));
    }
    final inline = el.attributes['style'];
    if (inline != null) {
      final decls = _parser.parseInlineStyle(inline);
      for (var i = 0; i < decls.length; i++) {
        entries.add(_Entry(decls[i], 2, 0, 0, i));
      }
    }
    entries.sort((a, b) => a.compareTo(b));

    // Custom properties first so var() can refer to any of them.
    final custom = Map<String, String>.from(parent.custom);
    for (final e in entries) {
      if (e.decl.property.startsWith('--')) {
        custom[e.decl.property] = e.decl.value;
      }
    }

    final own = <String, String>{};
    for (final e in entries) {
      final prop = e.decl.property;
      if (prop.startsWith('--')) continue;
      var value = e.decl.value;
      if (value.contains('var(')) {
        final substituted = _substituteVars(value, custom);
        if (substituted == null) {
          _warnings.add(
            'var:$prop',
            'CSS variable in "$prop" could not be resolved (${_describe(el)})',
            level: WarningLevel.info,
          );
          continue;
        }
        value = substituted;
      }
      final expanded = expandShorthand(prop, value);
      if (expanded != null) {
        if (expanded.isEmpty) {
          _warnings.add(
            'value:$prop',
            'Could not understand the value of "$prop": $value',
          );
          continue;
        }
        for (final kv in expanded.entries) {
          _apply(own, kv.key, kv.value, e.origin, el);
        }
      } else {
        _apply(own, prop, value, e.origin, el);
      }
    }

    return _finish(own, parent, custom);
  }

  void _apply(
    Map<String, String> own,
    String prop,
    String value,
    int origin,
    dom.Element el,
  ) {
    if (origin > 0 && !supportedProperties.contains(prop)) {
      _reportUnsupported(prop, el);
      return;
    }
    own[prop] = value;
  }

  void _reportUnsupported(String prop, dom.Element el) {
    final vendor =
        prop.startsWith('-webkit-') ||
        prop.startsWith('-moz-') ||
        prop.startsWith('-ms-');
    final info = vendor || _infoOnlyProperties.contains(prop);
    _warnings.add(
      'css:$prop',
      info
          ? 'CSS property "$prop" has no effect in a static Flutter conversion '
                '(first seen on ${_describe(el)})'
          : 'Unsupported CSS property "$prop" was ignored '
                '(first seen on ${_describe(el)})',
      level: info ? WarningLevel.info : WarningLevel.warning,
      feature: info ? null : prop,
    );
  }

  static String _describe(dom.Element el) {
    final cls = el.classes.isEmpty ? '' : '.${el.classes.first}';
    final id = el.id.isEmpty ? '' : '#${el.id}';
    return '<${el.localName}$id$cls>';
  }

  static final _varPattern = RegExp(
    r'var\(\s*(--[\w-]+)\s*(?:,\s*([^()]*(?:\([^()]*\)[^()]*)*))?\)',
  );

  String? _substituteVars(String value, Map<String, String> custom) {
    var out = value;
    for (var depth = 0; depth < 6 && out.contains('var('); depth++) {
      var failed = false;
      out = out.replaceAllMapped(_varPattern, (m) {
        final v = custom[m.group(1)!] ?? m.group(2);
        if (v == null) {
          failed = true;
          return '';
        }
        return v.trim();
      });
      if (failed) return null;
    }
    return out.contains('var(') ? null : out;
  }

  ComputedStyle _finish(
    Map<String, String> own,
    ComputedStyle parent,
    Map<String, String> custom,
  ) {
    final props = <String, String>{};
    for (final p in _inheritedProperties) {
      final v = parent.props[p];
      if (v != null) props[p] = v;
    }
    for (final kv in own.entries) {
      final lower = kv.value.trim().toLowerCase();
      if (lower == 'inherit') {
        final v = parent.props[kv.key];
        if (v != null) {
          props[kv.key] = v;
        } else {
          props.remove(kv.key);
        }
      } else if (lower == 'initial' ||
          (lower == 'unset' && !_inheritedProperties.contains(kv.key))) {
        props.remove(kv.key);
      } else if (lower == 'unset') {
        continue;
      } else {
        props[kv.key] = kv.value.trim();
      }
    }

    // --- font size (inherited as an absolute px value)
    var fontSize = parent.fontSize;
    if (own.containsKey('font-size') && props.containsKey('font-size')) {
      fontSize =
          _computeFontSize(props['font-size']!, parent.fontSize) ??
          parent.fontSize;
    }
    props['font-size'] = '${fontSize}px';
    if (own['font-size']?.trim().toLowerCase() == 'inherit') {
      props['font-size'] = '${parent.fontSize}px';
    }

    // --- letter spacing
    final ls = own['letter-spacing'];
    if (ls != null && props['letter-spacing'] != null) {
      final px = parsePx(ls, fontSize: fontSize);
      if (px != null) {
        props['letter-spacing'] = '${px}px';
      } else {
        props.remove('letter-spacing');
      }
    }

    // --- line height (unitless multiplier or px)
    final lh = own['line-height'];
    if (lh != null && props['line-height'] != null) {
      final t = lh.trim().toLowerCase();
      if (RegExp(r'^\d*\.?\d+$').hasMatch(t)) {
        props['line-height'] = t;
      } else if (t.endsWith('%')) {
        final p = double.tryParse(t.substring(0, t.length - 1));
        if (p != null) {
          props['line-height'] = '${round3(p / 100)}';
        } else {
          props.remove('line-height');
        }
      } else {
        final px = parsePx(t, fontSize: fontSize);
        if (px != null) {
          props['line-height'] = '${round3(px / fontSize)}';
        } else {
          props.remove('line-height');
        }
      }
    }

    // --- font weight (numeric)
    final fw = own['font-weight'];
    if (fw != null && props['font-weight'] != null) {
      final parentWeight =
          int.tryParse(parent.props['font-weight'] ?? '') ?? 400;
      final t = fw.trim().toLowerCase();
      int? w;
      switch (t) {
        case 'normal':
          w = 400;
        case 'bold':
          w = 700;
        case 'bolder':
          w = math.min(900, parentWeight + 300);
        case 'lighter':
          w = math.max(100, parentWeight - 200);
        case 'inherit':
          w = parentWeight;
        default:
          w = int.tryParse(t);
      }
      if (w == null) {
        props.remove('font-weight');
      } else {
        props['font-weight'] = '${((w / 100).round() * 100).clamp(100, 900)}';
      }
    }

    // --- color
    var color = parent.color;
    final c = own['color'];
    if (c != null) {
      final t = c.trim().toLowerCase();
      if (t != 'inherit' && t != 'currentcolor' && t != 'unset') {
        final parsed = parseColor(t, currentColor: parent.color);
        if (parsed != null) {
          color = parsed;
        } else if (t != 'initial') {
          _warnings.add('color:$t', 'Invalid color value "$c" was ignored');
        } else {
          color = 0xFF000000;
        }
      }
    }
    props.remove('color');

    return ComputedStyle(props, custom, fontSize, color);
  }

  double? _computeFontSize(String raw, double parentSize) {
    final t = raw.trim().toLowerCase();
    if (fontSizeKeywords.containsKey(t)) return fontSizeKeywords[t];
    if (t == 'smaller') return round3(parentSize / 1.2);
    if (t == 'larger') return round3(parentSize * 1.2);
    final len = parseLen(t, fontSize: parentSize);
    if (len == null) return null;
    if (len.isPercent) return round3(parentSize * len.value / 100);
    if (!len.isPx) return null;
    return len.value;
  }
}
