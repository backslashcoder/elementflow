import '../models/conversion_result.dart';
import '../models/ui_node.dart';
import '../models/ui_style.dart';
import 'generated_helpers.dart';
import 'ui_helpers.dart';

// ---------------------------------------------------------------------------
// Tiny expression tree. It lets the generator decide `const` and line
// breaking after the children are known.
// ---------------------------------------------------------------------------

abstract class _E {
  bool get isConst;
  String render(int indent, bool inConst);
}

class _Raw extends _E {
  _Raw(this.code, {this.isConst = true});
  final String code;
  @override
  final bool isConst;

  @override
  String render(int indent, bool inConst) => code;
}

class _Arg {
  _Arg(this.name, this.value);
  final String? name;
  final _E value;
}

class _Call extends _E {
  _Call(this.name, this.args, {this.constCapable = true});
  final String name;
  final List<_Arg> args;
  final bool constCapable;

  @override
  bool get isConst => constCapable && args.every((a) => a.value.isConst);

  @override
  String render(int indent, bool inConst) {
    final prefix = isConst && !inConst ? 'const ' : '';
    final childConst = inConst || isConst;
    if (args.isEmpty) return '$prefix$name()';
    final parts = [
      for (final a in args)
        '${a.name != null ? '${a.name}: ' : ''}${a.value.render(indent + 2, childConst)}',
    ];
    final single = '$prefix$name(${parts.join(', ')})';
    if (!single.contains('\n') && indent + single.length <= 78) return single;
    final pad = ' ' * (indent + 2);
    return '$prefix$name(\n${parts.map((p) => '$pad$p,').join('\n')}\n${' ' * indent})';
  }
}

/// `(params) => body`
class _Arrow extends _E {
  _Arrow(this.params, this.body);
  final String params;
  final _E body;

  @override
  bool get isConst => false;

  @override
  String render(int indent, bool inConst) =>
      '$params => ${body.render(indent, false)}';
}

class _ListE extends _E {
  _ListE(this.items);
  final List<_E> items;

  @override
  bool get isConst => items.every((i) => i.isConst);

  @override
  String render(int indent, bool inConst) {
    final prefix = isConst && !inConst && items.isNotEmpty ? 'const ' : '';
    final childConst = inConst || isConst;
    if (items.isEmpty) return '$prefix[]';
    final parts = [for (final i in items) i.render(indent + 2, childConst)];
    final single = '$prefix[${parts.join(', ')}]';
    if (!single.contains('\n') && indent + single.length <= 78) return single;
    final pad = ' ' * (indent + 2);
    return '$prefix[\n${parts.map((p) => '$pad$p,').join('\n')}\n${' ' * indent}]';
  }
}

_Arg _a(String name, _E v) => _Arg(name, v);
_Arg _p(_E v) => _Arg(null, v);
_E _lit(String s) => _Raw(s);
_E _dyn(String s) => _Raw(s, isConst: false);

// ---------------------------------------------------------------------------

/// Output of the generator.
class GeneratedCode {
  const GeneratedCode(this.source, this.lineCount, this.widgetCount);
  final String source;
  final int lineCount;
  final int widgetCount;
}

/// Turns the [UiNode] tree of a [ConversionResult] into one self-contained
/// Dart file.
class DartCodeGenerator {
  late _Context _ctx;

  GeneratedCode generate(ConversionResult result) {
    _ctx = _Context();
    final rootExpr = _widget(result.root, depth: 0);

    final b = StringBuffer()
      ..writeln('// ignore_for_file: unused_element_parameter')
      ..writeln()
      ..writeln("import 'package:flutter/material.dart';")
      ..writeln()
      ..writeln('void main() {')
      ..writeln('  runApp(const GeneratedApp());')
      ..writeln('}')
      ..writeln()
      ..writeln('class GeneratedApp extends StatelessWidget {')
      ..writeln('  const GeneratedApp({super.key});')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  Widget build(BuildContext context) {')
      ..writeln('    return MaterialApp(')
      ..writeln('      debugShowCheckedModeBanner: false,')
      ..writeln(
        "      title: ${_str(result.title.isEmpty ? 'ElementFlow Page' : result.title)},",
      )
      ..writeln('      theme: ThemeData(')
      ..writeln('        useMaterial3: true,')
      ..writeln('        colorSchemeSeed: const Color($_accent),')
      ..writeln('      ),')
      ..writeln('      home: const GeneratedPage(),')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('}')
      ..writeln()
      ..writeln('class GeneratedPage extends StatelessWidget {')
      ..writeln('  const GeneratedPage({super.key});')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  Widget build(BuildContext context) {');

    final bg = result.pageBackground ?? 0xFFFFFFFF;
    final page = _Call('Scaffold', [
      _a('backgroundColor', _color(bg)),
      _a(
        'body',
        _Call('DefaultTextStyle', [
          _a(
            'style',
            _Call('TextStyle', [
              _a('color', _color(0xFF000000)),
              _a('fontSize', _lit('16')),
              _a('fontWeight', _lit('FontWeight.w400')),
            ]),
          ),
          _a('child', _Call('SingleChildScrollView', [_a('child', rootExpr)])),
        ]),
      ),
    ]);
    b
      ..writeln('    return ${page.render(4, false)};')
      ..writeln('  }')
      ..writeln('}');

    // Extracted section widgets (may enqueue more while generating).
    for (var i = 0; i < _ctx.sections.length; i++) {
      final s = _ctx.sections[i];
      final expr = _placed(s.node, s.depth);
      b
        ..writeln()
        ..writeln('class ${s.name} extends StatelessWidget {')
        ..writeln('  const ${s.name}();')
        ..writeln()
        ..writeln('  @override')
        ..writeln('  Widget build(BuildContext context) {')
        ..writeln('    return ${expr.render(4, false)};')
        ..writeln('  }')
        ..writeln('}');
    }

    if (_ctx.usesPlaceholder) {
      b
        ..writeln()
        ..writeln('class _ImagePlaceholder extends StatelessWidget {')
        ..writeln('  const _ImagePlaceholder({this.width, this.height});')
        ..writeln()
        ..writeln('  final double? width;')
        ..writeln('  final double? height;')
        ..writeln()
        ..writeln('  @override')
        ..writeln('  Widget build(BuildContext context) {')
        ..writeln('    return Container(')
        ..writeln('      width: width ?? ${_n(placeholderWidth)},')
        ..writeln('      height: height ?? ${_n(placeholderHeight)},')
        ..writeln('      color: const Color(0xFFEEEEEE),')
        ..writeln('      alignment: Alignment.center,')
        ..writeln('      child: const Icon(')
        ..writeln('        Icons.image_not_supported_outlined,')
        ..writeln('        color: Color(0xFF9E9E9E),')
        ..writeln('      ),')
        ..writeln('    );')
        ..writeln('  }')
        ..writeln('}');
    }

    for (final (used, code) in [
      (_ctx.usesCheckbox, generatedCheckbox),
      (_ctx.usesRadio, generatedRadio),
      (_ctx.usesSlider, generatedSlider),
      (_ctx.usesSelect, generatedSelect),
    ]) {
      if (used) {
        b
          ..writeln()
          ..write(code);
      }
    }

    final source = b.toString();
    return GeneratedCode(
      source,
      '\n'.allMatches(source).length,
      result.root.size,
    );
  }

  static const _accent = '0xFF0075FF';

  // --------------------------------------------------------- primitives

  static String _n(num v) {
    if (v == double.infinity) return 'double.infinity';
    final d = v.toDouble();
    if (d == d.roundToDouble()) return d.toInt().toString();
    var s = d.toStringAsFixed(3);
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    return s;
  }

  static String _str(String s) {
    final b = StringBuffer("'");
    for (final r in s.runes) {
      switch (r) {
        case 0x5C:
          b.write(r'\\');
        case 0x27:
          b.write(r"\'");
        case 0x24:
          b.write(r'\$');
        case 0x0A:
          b.write(r'\n');
        case 0x0D:
          b.write(r'\r');
        case 0x09:
          b.write(r'\t');
        default:
          if (r < 0x20 ||
              r == 0x7F ||
              (r >= 0x80 && r < 0xA0) ||
              r == 0x2028 ||
              r == 0x2029) {
            b.write('\\u{${r.toRadixString(16).toUpperCase()}}');
          } else {
            b.writeCharCode(r);
          }
      }
    }
    b.write("'");
    return b.toString();
  }

  static _E _color(int argb) => _Call('Color', [
    _p(_lit('0x${argb.toRadixString(16).toUpperCase().padLeft(8, '0')}')),
  ]);

  _E _lenExpr(UiLen l, {required bool horizontal}) {
    switch (l.unit) {
      case UiUnit.px:
        return _lit(_n(l.value));
      case UiUnit.vw:
        return _dyn('MediaQuery.sizeOf(context).width * ${_n(l.value / 100)}');
      case UiUnit.vh:
        return _dyn('MediaQuery.sizeOf(context).height * ${_n(l.value / 100)}');
      case UiUnit.percent:
        return _lit(_n(l.value));
    }
  }

  static _E _insets(UiInsets i) {
    if (i.isUniform) return _Call('EdgeInsets.all', [_p(_lit(_n(i.top)))]);
    if (i.top == i.bottom && i.left == i.right) {
      if (i.left == 0) {
        return _Call('EdgeInsets.symmetric', [_a('vertical', _lit(_n(i.top)))]);
      }
      if (i.top == 0) {
        return _Call('EdgeInsets.symmetric', [
          _a('horizontal', _lit(_n(i.left))),
        ]);
      }
      return _Call('EdgeInsets.symmetric', [
        _a('vertical', _lit(_n(i.top))),
        _a('horizontal', _lit(_n(i.left))),
      ]);
    }
    final sides = [
      (i.left, 'left'),
      (i.top, 'top'),
      (i.right, 'right'),
      (i.bottom, 'bottom'),
    ].where((e) => e.$1 != 0).toList();
    if (sides.length <= 2) {
      return _Call('EdgeInsets.only', [
        for (final e in sides) _a(e.$2, _lit(_n(e.$1))),
      ]);
    }
    return _Call('EdgeInsets.fromLTRB', [
      _p(_lit(_n(i.left))),
      _p(_lit(_n(i.top))),
      _p(_lit(_n(i.right))),
      _p(_lit(_n(i.bottom))),
    ]);
  }

  static _E _alignmentExpr(double x, double y) {
    final name = alignmentName(x, y);
    if (name != null) return _lit('Alignment.$name');
    return _Call('Alignment', [_p(_lit(_n(x))), _p(_lit(_n(y)))]);
  }

  static _E _borderSide(UiBorderSide s) => _Call('BorderSide', [
    _a('color', _color(s.color)),
    if (s.width != 1) _a('width', _lit(_n(s.width))),
  ]);

  static _E _borderRadius(UiRadius r) {
    if (r.isUniform) {
      return _Call('BorderRadius.circular', [
        _p(_lit(_n(r.topLeft))),
      ], constCapable: false);
    }
    return _Call('BorderRadius.only', [
      if (r.topLeft != 0)
        _a('topLeft', _Call('Radius.circular', [_p(_lit(_n(r.topLeft)))])),
      if (r.topRight != 0)
        _a('topRight', _Call('Radius.circular', [_p(_lit(_n(r.topRight)))])),
      if (r.bottomLeft != 0)
        _a(
          'bottomLeft',
          _Call('Radius.circular', [_p(_lit(_n(r.bottomLeft)))]),
        ),
      if (r.bottomRight != 0)
        _a(
          'bottomRight',
          _Call('Radius.circular', [_p(_lit(_n(r.bottomRight)))]),
        ),
    ]);
  }

  static _E _border(UiBorder b) {
    if (b.isUniform) {
      final s = b.top!;
      return _Call('Border.all', [
        _a('color', _color(s.color)),
        if (s.width != 1) _a('width', _lit(_n(s.width))),
      ], constCapable: false);
    }
    return _Call('Border', [
      if (b.top != null) _a('top', _borderSide(b.top!)),
      if (b.right != null) _a('right', _borderSide(b.right!)),
      if (b.bottom != null) _a('bottom', _borderSide(b.bottom!)),
      if (b.left != null) _a('left', _borderSide(b.left!)),
    ]);
  }

  static _E _boxDecoration(UiBox b) => _Call('BoxDecoration', [
    if (b.background != null) _a('color', _color(b.background!)),
    if (b.gradient != null) _a('gradient', _gradient(b.gradient!)),
    if (b.hasBorder) _a('border', _border(b.border!)),
    if (b.radius != null && !b.radius!.isZero)
      _a('borderRadius', _borderRadius(b.radius!)),
    if (b.shadows.isNotEmpty)
      _a(
        'boxShadow',
        _ListE([
          for (final s in b.shadows)
            _Call('BoxShadow', [
              _a('color', _color(s.color)),
              _a(
                'offset',
                _Call('Offset', [_p(_lit(_n(s.dx))), _p(_lit(_n(s.dy)))]),
              ),
              if (s.blur != 0) _a('blurRadius', _lit(_n(s.blur))),
              if (s.spread != 0) _a('spreadRadius', _lit(_n(s.spread))),
            ]),
        ]),
      ),
  ]);

  static _E _gradient(UiGradient g) => _Call('LinearGradient', [
    _a('begin', _alignmentExpr(g.beginX, g.beginY)),
    _a('end', _alignmentExpr(g.endX, g.endY)),
    _a('colors', _ListE([for (final c in g.colors) _color(c)])),
    if (g.stops != null)
      _a('stops', _ListE([for (final s in g.stops!) _lit(_n(s))])),
  ]);

  static _E? _textStyle(UiTextStyle s, UiTextStyle base, {bool full = false}) {
    final d = diffTextStyle(s, base, full: full);
    if (d.isEmpty) return null;
    _E? deco;
    if (d.hasDecoration) {
      final parts = [
        if (d.underline!) 'TextDecoration.underline',
        if (d.lineThrough!) 'TextDecoration.lineThrough',
        if (d.overline!) 'TextDecoration.overline',
      ];
      deco = parts.isEmpty
          ? _lit('TextDecoration.none')
          : parts.length == 1
          ? _lit(parts.first)
          : _Call(
              'TextDecoration.combine',
              [
                _p(_ListE([for (final p in parts) _lit(p)])),
              ],
              constCapable: false, // a factory constructor
            );
    }
    return _Call('TextStyle', [
      if (d.color != null) _a('color', _color(d.color!)),
      if (d.fontSize != null) _a('fontSize', _lit(_n(d.fontSize!))),
      if (d.weight != null) _a('fontWeight', _lit('FontWeight.w${d.weight}')),
      if (d.italic != null)
        _a(
          'fontStyle',
          _lit(d.italic! ? 'FontStyle.italic' : 'FontStyle.normal'),
        ),
      if (deco != null) _a('decoration', deco),
      if (d.fontFamily != null) _a('fontFamily', _lit(_str(d.fontFamily!))),
      if (d.height != null) _a('height', _lit(_n(d.height!))),
      if (d.letterSpacing != null)
        _a('letterSpacing', _lit(_n(d.letterSpacing!))),
    ]);
  }

  // -------------------------------------------------------------- nodes

  static const _sectionTags = {
    'header',
    'nav',
    'main',
    'section',
    'article',
    'aside',
    'footer',
    'form',
    'ul',
    'ol',
    'table',
    'figure',
    'blockquote',
    'fieldset',
  };

  bool _shouldExtract(UiNode n, int depth) =>
      depth >= 1 &&
      depth <= 3 &&
      (n.kind == UiKind.column ||
          n.kind == UiKind.row ||
          n.kind == UiKind.wrap) &&
      _sectionTags.contains(n.tag) &&
      n.size >= 8;

  /// Builds the expression for [n] including flex/alignment wrappers.
  _E _widget(UiNode n, {required int depth}) {
    if (_shouldExtract(n, depth)) {
      final name = _ctx.sectionFor(n, depth);
      return _flexWrap(n, _Call(name, []));
    }
    return _flexWrap(n, _placed(n, depth));
  }

  _E _flexWrap(UiNode n, _E w) {
    if (n.flex == null) return w;
    return _Call(n.flexTight ? 'Expanded' : 'Flexible', [
      if (n.flex != 1) _a('flex', _lit('${n.flex}')),
      _a('child', w),
    ]);
  }

  /// Placement, opacity and box wrappers around the node's content.
  _E _placed(UiNode n, int depth) {
    _E w = _boxed(n, depth);
    if (n.box.opacity < 1) {
      w = _Call('Opacity', [
        _a('opacity', _lit(_n(n.box.opacity))),
        _a('child', w),
      ]);
    }
    if (n.widthFactor != null) {
      final al = nodeAlignment(n) ?? (-1.0, -1.0);
      w = _Call('FractionallySizedBox', [
        _a('alignment', _alignmentExpr(al.$1, al.$2)),
        _a('widthFactor', _lit(_n(n.widthFactor!))),
        _a('child', w),
      ]);
    } else {
      final al = nodeAlignment(n);
      if (al != null) {
        w = _Call('Align', [
          _a('alignment', _alignmentExpr(al.$1, al.$2)),
          _a('child', w),
        ]);
      }
    }
    return w;
  }

  _E _boxed(UiNode n, int depth) {
    final plan = planBox(n);
    final b = n.box;
    final content = _content(n, depth);

    if (plan.categories == 0) return content ?? _Call('SizedBox.shrink', []);

    if (plan.categories == 1) {
      if (plan.padding) {
        return _Call('Padding', [
          _a('padding', _insets(b.padding)),
          if (content != null) _a('child', content),
        ]);
      }
      if (plan.margin) {
        return _Call('Padding', [
          _a('padding', _insets(b.margin)),
          if (content != null) _a('child', content),
        ]);
      }
      if (plan.size) {
        return _Call('SizedBox', [
          if (b.width != null)
            _a('width', _lenExpr(b.width!, horizontal: true)),
          if (b.height != null)
            _a('height', _lenExpr(b.height!, horizontal: false)),
          if (content != null) _a('child', content),
        ]);
      }
    }

    return _Call('Container', [
      if (plan.size && b.width != null)
        _a('width', _lenExpr(b.width!, horizontal: true)),
      if (plan.size && b.height != null)
        _a('height', _lenExpr(b.height!, horizontal: false)),
      if (plan.constraints)
        _a(
          'constraints',
          _Call('BoxConstraints', [
            if (b.minWidth != null)
              _a('minWidth', _lenExpr(b.minWidth!, horizontal: true)),
            if (b.maxWidth != null)
              _a('maxWidth', _lenExpr(b.maxWidth!, horizontal: true)),
            if (b.minHeight != null)
              _a('minHeight', _lenExpr(b.minHeight!, horizontal: false)),
            if (b.maxHeight != null)
              _a('maxHeight', _lenExpr(b.maxHeight!, horizontal: false)),
          ]),
        ),
      if (plan.padding) _a('padding', _insets(b.padding)),
      if (plan.margin) _a('margin', _insets(b.margin)),
      if (plan.decoration && plan.colorOnly && !plan.clip)
        _a('color', _color(b.background!))
      else if (plan.decoration)
        _a('decoration', _boxDecoration(b)),
      if (plan.clip) _a('clipBehavior', _lit('Clip.antiAlias')),
      if (content != null) _a('child', content),
    ], constCapable: false); // Container has no const constructor
  }

  _E? _content(UiNode n, int depth) {
    switch (n.kind) {
      case UiKind.column:
        return _column(n, depth);
      case UiKind.row:
        return _row(n, depth);
      case UiKind.wrap:
        return _wrap(n, depth);
      case UiKind.text:
        return _text(n, depth);
      case UiKind.image:
        return _image(n);
      case UiKind.button:
        return _button(n);
      case UiKind.textField:
        return _textField(n);
      case UiKind.checkbox:
        _ctx.usesCheckbox = true;
        return _Call('_EfCheckbox', [_a('initial', _lit('${n.checked}'))]);
      case UiKind.radio:
        _ctx.usesRadio = true;
        return _Call('_EfRadio', [
          _a('group', _lit(_str(n.group))),
          _a('id', _lit('${n.id}')),
          _a('initial', _lit('${n.checked}')),
        ]);
      case UiKind.slider:
        _ctx.usesSlider = true;
        return _Call('_EfSlider', [_a('initial', _lit(n.value ?? '0.5'))]);
      case UiKind.select:
        _ctx.usesSelect = true;
        return _select(n);
      case UiKind.divider:
        final t = n.dividerThickness;
        return _Call('Divider', [
          _a('height', _lit(_n(t))),
          _a('thickness', _lit(_n(t))),
          _a('color', _color(n.dividerColor)),
        ]);
    }
  }

  List<_E> _children(UiNode n, int depth) => [
    for (final c in n.children) _widget(c, depth: depth + 1),
  ];

  _E? _column(UiNode n, int depth) {
    if (n.children.isEmpty) return null;
    if (collapsesToChild(n)) return _widget(n.children.first, depth: depth + 1);
    return _Call('Column', [
      if (n.mainAxis != UiMain.start)
        _a('mainAxisAlignment', _lit('MainAxisAlignment.${n.mainAxis.name}')),
      if (n.crossAxis != UiCross.center)
        _a(
          'crossAxisAlignment',
          _lit('CrossAxisAlignment.${n.crossAxis.name}'),
        ),
      if (n.gap != 0) _a('spacing', _lit(_n(n.gap))),
      _a('children', _ListE(_children(n, depth))),
    ]);
  }

  _E? _row(UiNode n, int depth) {
    if (n.children.isEmpty) return null;
    _E row = _Call('Row', [
      if (n.mainAxis != UiMain.start)
        _a('mainAxisAlignment', _lit('MainAxisAlignment.${n.mainAxis.name}')),
      if (n.crossAxis != UiCross.center)
        _a(
          'crossAxisAlignment',
          _lit('CrossAxisAlignment.${n.crossAxis.name}'),
        ),
      if (n.shrinkWrap) _a('mainAxisSize', _lit('MainAxisSize.min')),
      if (n.gap != 0) _a('spacing', _lit(_n(n.gap))),
      _a('children', _ListE(_children(n, depth))),
    ]);
    if (n.intrinsicHeight) row = _Call('IntrinsicHeight', [_a('child', row)]);
    return row;
  }

  _E? _wrap(UiNode n, int depth) {
    if (n.children.isEmpty) return null;
    return _Call('Wrap', [
      if (n.gap != 0) _a('spacing', _lit(_n(n.gap))),
      if (n.runGap != 0) _a('runSpacing', _lit(_n(n.runGap))),
      if (n.mainAxis != UiMain.start)
        _a('alignment', _lit('WrapAlignment.${n.mainAxis.name}')),
      if (n.crossAxis != UiCross.start)
        _a(
          'crossAxisAlignment',
          _lit('WrapCrossAlignment.${n.crossAxis.name}'),
        ),
      _a('children', _ListE(_children(n, depth))),
    ]);
  }

  // ---------------------------------------------------------------- text

  _E _text(UiNode n, int depth) {
    final spans = n.spans;
    final align = textAlignName(n.textAlign);
    final extras = <_Arg>[
      if (align != null) _a('textAlign', _lit('TextAlign.$align')),
      if (!n.softWrap) _a('softWrap', _lit('false')),
      if (n.maxLines != null) _a('maxLines', _lit('${n.maxLines}')),
      if (n.ellipsis) _a('overflow', _lit('TextOverflow.ellipsis')),
    ];

    final simple = spans.length == 1 && spans[0].widget == null;
    if (simple) {
      final style = _textStyle(spans[0].style, UiTextStyle.base);
      return _Call('Text', [
        _p(_lit(_str(spans[0].text!))),
        if (style != null) _a('style', style),
        ...extras,
      ]);
    }

    final children = <_E>[];
    for (final s in spans) {
      if (s.widget != null) {
        children.add(
          _Call('WidgetSpan', [
            _a('alignment', _lit('PlaceholderAlignment.middle')),
            _a('child', _widget(s.widget!, depth: depth + 1)),
          ]),
        );
      } else {
        final style = _textStyle(s.style, n.textStyle);
        children.add(
          _Call('TextSpan', [
            _a('text', _lit(_str(s.text!))),
            if (style != null) _a('style', style),
          ]),
        );
      }
    }
    final rootStyle = _textStyle(n.textStyle, UiTextStyle.base);
    return _Call('Text.rich', [
      _p(
        _Call('TextSpan', [
          if (rootStyle != null) _a('style', rootStyle),
          _a('children', _ListE(children)),
        ]),
      ),
      ...extras,
    ]);
  }

  // -------------------------------------------------------------- image

  _E _image(UiNode n) {
    final w = n.box.width, h = n.box.height;
    final wExpr = w == null ? null : _lenExpr(w, horizontal: true);
    final hExpr = h == null ? null : _lenExpr(h, horizontal: false);
    _E placeholder() {
      _ctx.usesPlaceholder = true;
      final dynamicSize =
          (wExpr != null && !wExpr.isConst) ||
          (hExpr != null && !hExpr.isConst);
      return _Call('_ImagePlaceholder', [
        if (wExpr != null) _a('width', wExpr),
        if (hExpr != null) _a('height', hExpr),
      ], constCapable: !dynamicSize);
    }

    if (n.src == null || n.src!.isEmpty) return placeholder();
    return _Call('Image.network', [
      _p(_lit(_str(n.src!))),
      if (wExpr != null) _a('width', wExpr),
      if (hExpr != null) _a('height', hExpr),
      if (n.fit != UiFit.fill) _a('fit', _lit('BoxFit.${fitName(n.fit)}')),
      _a('webHtmlElementStrategy', _lit('WebHtmlElementStrategy.fallback')),
      _a('errorBuilder', _Arrow('(context, error, stackTrace)', placeholder())),
    ], constCapable: false);
  }

  // ----------------------------------------------------------- controls

  _E _button(UiNode n) {
    final c = n.control;
    final ts = n.textStyle;
    final textStyle = _textStyle(ts, UiTextStyle.base, full: true)!;
    final hasShape = c.radius > 0 || c.border != null;
    return _Call('ElevatedButton', [
      _a('onPressed', _dyn('() {}')),
      _a(
        'style',
        _Call('ElevatedButton.styleFrom', [
          _a('backgroundColor', _color(c.fill ?? 0x00000000)),
          _a('foregroundColor', _color(ts.color)),
          _a('elevation', _lit(c.hasShadow ? '2' : '0')),
          _a('padding', _insets(c.padding)),
          _a('minimumSize', _lit('Size.zero')),
          _a('tapTargetSize', _lit('MaterialTapTargetSize.shrinkWrap')),
          if (hasShape)
            _a(
              'shape',
              _Call('RoundedRectangleBorder', [
                if (c.radius > 0)
                  _a(
                    'borderRadius',
                    _Call('BorderRadius.circular', [
                      _p(_lit(_n(c.radius))),
                    ], constCapable: false),
                  ),
                if (c.border != null) _a('side', _borderSide(c.border!)),
              ]),
            ),
          _a('textStyle', textStyle),
        ], constCapable: false),
      ),
      _a('child', _Call('Text', [_p(_lit(_str(n.value ?? '')))])),
    ], constCapable: false);
  }

  _E _inputDecoration(UiNode n, {_E? suffixIcon}) {
    final c = n.control;
    return _Call('InputDecoration', [
      _a('isDense', _lit('true')),
      if (n.hint != null) _a('hintText', _lit(_str(n.hint!))),
      if (c.fill != null) _a('filled', _lit('true')),
      if (c.fill != null) _a('fillColor', _color(c.fill!)),
      _a('contentPadding', _insets(c.padding)),
      if (suffixIcon != null) _a('suffixIcon', suffixIcon),
      _a(
        'border',
        c.border == null
            ? _lit('InputBorder.none')
            : _Call('OutlineInputBorder', [
                _a(
                  'borderRadius',
                  _Call('BorderRadius.circular', [
                    _p(_lit(_n(c.radius))),
                  ], constCapable: false),
                ),
                _a('borderSide', _borderSide(c.border!)),
              ]),
      ),
    ]);
  }

  _E _textField(UiNode n) {
    final style = _textStyle(n.textStyle, UiTextStyle.base, full: true)!;
    final expands = n.lines == 0;
    final hasValue = n.value != null && n.value!.isNotEmpty;
    return _Call(hasValue ? 'TextFormField' : 'TextField', [
      if (hasValue) _a('initialValue', _lit(_str(n.value!))),
      if (n.obscure) _a('obscureText', _lit('true')),
      _a('style', style),
      if (expands) ...[
        _a('maxLines', _lit('null')),
        _a('expands', _lit('true')),
        _a('textAlignVertical', _lit('TextAlignVertical.top')),
      ] else if (n.lines > 1) ...[
        _a('minLines', _lit('${n.lines}')),
        _a('maxLines', _lit('${n.lines}')),
      ],
      _a('decoration', _inputDecoration(n)),
    ], constCapable: !hasValue);
  }

  _E _select(UiNode n) {
    final style = _textStyle(n.textStyle, UiTextStyle.base, full: true)!;
    return _Call('_EfSelect', [
      _a('options', _ListE([for (final o in n.options) _lit(_str(o))])),
      _a('initial', _lit('${n.selectedIndex}')),
      _a('style', style),
      _a('decoration', _inputDecoration(n)),
    ]);
  }
}

class _Section {
  _Section(this.name, this.node, this.depth);
  final String name;
  final UiNode node;
  final int depth;
}

class _Context {
  final sections = <_Section>[];
  final _byNode = <UiNode, String>{};
  final _used = <String>{};
  bool usesPlaceholder = false;
  bool usesCheckbox = false, usesRadio = false;
  bool usesSlider = false, usesSelect = false;

  String sectionFor(UiNode n, int depth) {
    final existing = _byNode[n];
    if (existing != null) return existing;
    final base = _pascal(n.label ?? n.tag);
    var name = '_${base.isEmpty ? 'Block' : base}Section';
    var i = 2;
    while (_used.contains(name)) {
      name = '_${base.isEmpty ? 'Block' : base}Section$i';
      i++;
    }
    _used.add(name);
    _byNode[n] = name;
    sections.add(_Section(name, n, depth));
    return name;
  }

  static String _pascal(String s) {
    final parts = s
        .split(RegExp(r'[^A-Za-z0-9]+'))
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join();
    if (parts.isEmpty) return '';
    return RegExp(r'^[0-9]').hasMatch(parts) ? 'X$parts' : parts;
  }
}
