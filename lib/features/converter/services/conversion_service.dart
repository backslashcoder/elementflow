import 'dart:math' as math;

import 'package:html/dom.dart' as dom;

import '../models/conversion_result.dart';
import '../models/ui_node.dart';
import '../models/ui_style.dart';
import 'css_parser_service.dart';
import 'css_values.dart';
import 'html_parser_service.dart';
import 'style_mapper.dart';
import 'style_resolver.dart';
import 'warning_collector.dart';

/// Converts HTML + CSS into the [UiNode] intermediate representation.
///
/// The conversion is deterministic: identical input always yields an
/// identical tree and identical warnings.
class ConversionService {
  ConversionService({HtmlParserService? html, CssParserService? css})
    : _html = html ?? HtmlParserService(),
      _css = css ?? CssParserService();

  final HtmlParserService _html;
  final CssParserService _css;

  ConversionResult convert(String source) {
    final parsed = _html.parse(source);
    final warnings = WarningCollector();

    if (parsed.parseIssues.isNotEmpty) {
      final shown = parsed.parseIssues.take(3).join('; ');
      warnings.add(
        'malformed',
        'Malformed HTML was repaired automatically '
            '(${parsed.parseIssues.length} issue(s), e.g. $shown)',
      );
    }
    if (parsed.externalStyleSheets.isNotEmpty) {
      warnings.add(
        'external-css',
        'External style sheets are not fetched: '
            '${parsed.externalStyleSheets.take(2).join(', ')}. '
            'Inline the CSS in a <style> tag to convert it.',
        feature: 'external stylesheet',
      );
    }
    if (parsed.scriptCount > 0) {
      warnings.add(
        'scripts',
        '${parsed.scriptCount} <script> element(s) were ignored; '
            'JavaScript is never executed or converted',
        level: WarningLevel.info,
      );
    }

    final rules = <CssRule>[];
    final ua = _css.parse(uaStylesheet, origin: 0);
    rules.addAll(ua.rules);
    var order = 0;
    final ignoredAtRules = <String>[];
    for (final sheet in parsed.styleSheets) {
      final r = _css.parse(sheet, origin: 1, startOrder: order);
      order += r.rules.length + 1;
      rules.addAll(r.rules);
      ignoredAtRules.addAll(r.ignoredAtRules);
      for (final m in r.messages) {
        warnings.add('css-msg:$m', m);
      }
    }
    for (final a in ignoredAtRules) {
      final name = a.split(RegExp(r'[\s(]')).first.toLowerCase();
      final cosmetic =
          name == '@font-face' ||
          name == '@keyframes' ||
          name == '@-webkit-keyframes' ||
          name == '@charset' ||
          name == '@supports';
      warnings.add(
        'at:$name',
        cosmetic
            ? '"$name" rules have no effect in the converted output'
            : '"$name" rules are not supported and were ignored (e.g. "$a")',
        level: cosmetic ? WarningLevel.info : WarningLevel.warning,
        feature: cosmetic ? null : name,
      );
    }

    final resolver = StyleResolver(rules, _css, warnings);
    final converter = _Converter(warnings, resolver);
    return converter.run(parsed);
  }
}

// ---------------------------------------------------------------------------

const _blockLevelDisplays = {
  'block',
  'flex',
  'grid',
  'table',
  'list-item',
  'table-row',
  'table-row-group',
  'table-cell',
  'table-caption',
  'flow-root',
};

const _inlineAtomicDisplays = {
  'inline-block',
  'inline-flex',
  'inline-grid',
  'inline-table',
};

const _blockTags = {
  'div',
  'p',
  'section',
  'article',
  'aside',
  'main',
  'header',
  'footer',
  'nav',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'ul',
  'ol',
  'li',
  'table',
  'form',
  'blockquote',
  'pre',
  'hr',
  'figure',
  'fieldset',
  'dl',
  'dt',
  'dd',
  'address',
  'details',
  'summary',
  'center',
};

const _unsupportedReplaced = {
  'svg',
  'canvas',
  'video',
  'audio',
  'iframe',
  'object',
  'embed',
  'map',
  'meter',
  'progress',
  'math',
};

const _atomicTags = {'img', 'input', 'button', 'select', 'textarea'};

class _FlowItem {
  _FlowItem(this.node, {this.atomic = false, this.isRun = false});
  UiNode node;

  /// Inline-level atomic content (image, button, inline-block...).
  final bool atomic;

  /// Anonymous text run that has no element of its own.
  final bool isRun;
}

class _Raw {
  _Raw.text(this.text, this.style, {this.pre = false})
    : widget = null,
      isBreak = false;
  _Raw.widget(UiNode this.widget)
    : text = '',
      style = UiTextStyle.base,
      pre = false,
      isBreak = false;
  _Raw.br(this.style) : text = '', widget = null, pre = false, isBreak = true;

  String text;
  final UiTextStyle style;
  final bool pre;
  final UiNode? widget;
  final bool isBreak;
}

class _Track {
  _Track({this.fixed, this.flex = 1});
  final double? fixed;
  final int flex;
}

class _Converter {
  _Converter(this.warnings, this.resolver) : mapper = StyleMapper(warnings);

  final WarningCollector warnings;
  final StyleResolver resolver;
  final StyleMapper mapper;

  final _styles = <dom.Element, ComputedStyle>{};
  var _controlId = 0;

  // ------------------------------------------------------------- entry

  ConversionResult run(ParsedHtml parsed) {
    final htmlEl = parsed.document.documentElement;
    final htmlStyle = htmlEl != null
        ? _style(htmlEl, ComputedStyle.root())
        : ComputedStyle.root();
    final body = parsed.body;
    final bodyStyle = identical(body, htmlEl)
        ? htmlStyle
        : _style(body, htmlStyle);

    final pageBg =
        mapper.backgroundColor(bodyStyle) ?? mapper.backgroundColor(htmlStyle);
    final root = _flowNode(body, bodyStyle, forceColumn: true);
    if (pageBg != null && root.box.background == pageBg) {
      root.box = root.box.copyWith(clearBackground: root.box.gradient == null);
    }
    if (root.box.gradient != null && root.box.minHeight == null) {
      root.box = root.box.copyWith(minHeight: const UiLen(100, UiUnit.vh));
    }

    return ConversionResult(
      root: root,
      pageBackground: pageBg,
      title: parsed.title,
      warnings: warnings.warnings,
      elementsProcessed: _styles.length,
      unsupportedFeatures: warnings.unsupportedFeatures.toList()..sort(),
    );
  }

  // ------------------------------------------------------------- styles

  ComputedStyle _style(dom.Element el, ComputedStyle parent) => _styles
      .putIfAbsent(el, () => resolver.compute(el, parent, hints: _hints(el)));

  List<CssDeclaration> _hints(dom.Element el) {
    final out = <CssDeclaration>[];
    final a = el.attributes;
    final tag = el.localName!;
    void add(String p, String v) => out.add(CssDeclaration(p, v));

    String? dim(String? v) {
      if (v == null) return null;
      final t = v.trim();
      if (RegExp(r'^\d+(\.\d+)?%$').hasMatch(t)) return t;
      final m = RegExp(r'^(\d+(?:\.\d+)?)(px)?$').firstMatch(t);
      return m == null ? null : '${m.group(1)}px';
    }

    if (const {
      'img',
      'table',
      'td',
      'th',
      'canvas',
      'video',
      'iframe',
      'svg',
    }.contains(tag)) {
      final w = dim(a['width']);
      final h = dim(a['height']);
      if (w != null) add('width', w);
      if (h != null && !h.endsWith('%')) add('height', h);
    }
    if (const {'body', 'table', 'tr', 'td', 'th'}.contains(tag) &&
        a['bgcolor'] != null) {
      add('background-color', a['bgcolor']!);
    }
    final align = a['align']?.toLowerCase();
    if (align != null &&
        const {'left', 'right', 'center', 'justify'}.contains(align) &&
        tag != 'table' &&
        tag != 'img') {
      add('text-align', align);
    }
    if (tag == 'font') {
      if (a['color'] != null) add('color', a['color']!);
      if (a['face'] != null) add('font-family', a['face']!);
    }
    if (tag == 'table') {
      final b = int.tryParse(a['border'] ?? '');
      if (b != null && b > 0) add('border', '${b}px solid #808080');
    }
    if (tag == 'td' || tag == 'th') {
      dom.Element? p = el.parent;
      while (p != null && p.localName != 'table') {
        p = p.parent;
      }
      if (p != null) {
        final b = int.tryParse(p.attributes['border'] ?? '');
        if (b != null && b > 0) add('border', '1px solid #808080');
        final cp = int.tryParse(p.attributes['cellpadding'] ?? '');
        if (cp != null) add('padding', '${cp}px');
      }
    }
    return out;
  }

  String? _label(dom.Element el) {
    if (el.id.isNotEmpty) return el.id;
    if (el.classes.isNotEmpty) return el.classes.first;
    return null;
  }

  bool _containsBlock(dom.Element el) {
    for (final c in el.children) {
      if (_blockTags.contains(c.localName)) return true;
      final d = c.attributes['style']?.toLowerCase() ?? '';
      if (RegExp(r'display\s*:\s*(block|flex|grid|table)').hasMatch(d)) {
        return true;
      }
      if (_containsBlock(c)) return true;
    }
    return false;
  }

  bool _needsBox(ComputedStyle s) {
    bool nonZero(String? v) {
      if (v == null) return false;
      final len = parseLen(v, fontSize: s.fontSize);
      return len == null || len.value != 0;
    }

    for (final p in const [
      'padding-top',
      'padding-right',
      'padding-bottom',
      'padding-left',
    ]) {
      if (nonZero(s[p])) return true;
    }
    final bg = s['background-color'];
    if (bg != null) {
      final c = parseColor(bg, currentColor: s.color);
      if (c != null && (c >> 24) != 0) return true;
    }
    final bgi = s['background-image'];
    if (bgi != null && bgi.toLowerCase() != 'none') return true;
    for (final side in const ['top', 'right', 'bottom', 'left']) {
      final st = (s['border-$side-style'] ?? 'none').toLowerCase();
      if (st != 'none' &&
          st != 'hidden' &&
          nonZero(s['border-$side-width'] ?? '3px')) {
        return true;
      }
    }
    final w = s['width'], h = s['height'];
    return (w != null && w.toLowerCase() != 'auto') ||
        (h != null && h.toLowerCase() != 'auto');
  }

  // --------------------------------------------------------- dispatching

  /// Converts [el] as a block-level box. Returns null for elements that
  /// produce no output (and reports unsupported ones).
  UiNode? _blockNode(dom.Element el, ComputedStyle s) {
    final tag = el.localName!;
    final pos = s['position']?.toLowerCase();
    if (pos == 'absolute' || pos == 'fixed' || pos == 'sticky') {
      warnings.add(
        'position:$pos',
        'position: $pos is not supported; elements are laid out in normal flow',
        feature: 'position: $pos',
      );
    }
    final fl = s['float']?.toLowerCase();
    if (fl == 'left' || fl == 'right') {
      warnings.add(
        'float:$fl',
        'float is not supported; floated elements are laid out in normal flow',
        feature: 'float',
      );
    }

    if (_unsupportedReplaced.contains(tag)) {
      warnings.add(
        'el:$tag',
        '<$tag> elements are not supported and were skipped',
        feature: '<$tag>',
      );
      return null;
    }
    switch (tag) {
      case 'img':
        return _image(el, s);
      case 'picture':
        final img = el.querySelector('img');
        if (img == null) return null;
        return _image(img, _style(img, s));
      case 'input':
        return _input(el, s);
      case 'button':
        return _button(el, s, _buttonLabel(el, s));
      case 'textarea':
        return _textarea(el, s);
      case 'select':
        return _select(el, s);
      case 'hr':
        return _divider(el, s);
    }
    if (tag.contains('-') && !_blockTags.contains(tag)) {
      warnings.add(
        'custom:$tag',
        'Custom element <$tag> was treated as a generic container',
        level: WarningLevel.info,
      );
    }
    final d = s.display;
    if (d == 'flex' || d == 'inline-flex') return _flex(el, s);
    if (d == 'grid' || d == 'inline-grid') return _grid(el, s);
    if (tag == 'table') return _table(el, s);
    if ((tag == 'ul' || tag == 'ol') && !_inlineAtomicDisplays.contains(d)) {
      return _list(el, s);
    }
    return _flowNode(el, s);
  }

  // ---------------------------------------------------------------- flow

  UiNode _flowNode(
    dom.Element el,
    ComputedStyle s, {
    bool forceColumn = false,
  }) {
    final tag = el.localName!;
    var box = mapper.box(s, tag: tag);
    final items = _flowChildren(el, s);

    if (!forceColumn &&
        items.length == 1 &&
        items[0].isRun &&
        !items[0].atomic) {
      return _retag(items[0].node, el, box);
    }

    final col = UiNode(UiKind.column, tag: tag, label: _label(el), box: box);
    col.crossAxis = UiCross.stretch;
    final align = mapper.textAlign(s);
    for (final it in items) {
      _placeInBlock(it.node, atomic: it.atomic, textAlign: align);
    }
    col.children = [for (final it in items) it.node];
    _collapseSiblingMargins(col.children);
    _collapseParentMargins(col);
    return col;
  }

  UiNode _retag(UiNode run, dom.Element el, UiBox box) {
    final n = UiNode(
      UiKind.text,
      tag: el.localName!,
      label: _label(el),
      box: box,
    );
    n.spans = run.spans;
    n.textStyle = run.textStyle;
    n.textAlign = run.textAlign;
    n.softWrap = run.softWrap;
    n.ellipsis = run.ellipsis;
    n.maxLines = run.maxLines;
    return n;
  }

  List<_FlowItem> _flowChildren(dom.Element el, ComputedStyle s) {
    final items = <_FlowItem>[];
    final run = <dom.Node>[];

    void flush() {
      if (run.isEmpty) return;
      final item = _runItem(List.of(run), s);
      if (item != null) items.add(item);
      run.clear();
    }

    for (final n in el.nodes) {
      if (n is dom.Text) {
        run.add(n);
        continue;
      }
      if (n is! dom.Element) continue;
      if (n.localName == 'br') {
        run.add(n);
        continue;
      }
      final cs = _style(n, s);
      if (cs.display == 'none') continue;
      if (_isBlockLevel(n, cs)) {
        flush();
        final node = _blockNode(n, cs);
        if (node != null) {
          items.add(_FlowItem(node, atomic: _isAtomicKind(node)));
        }
      } else {
        run.add(n);
      }
    }
    flush();
    return items;
  }

  bool _isAtomicKind(UiNode n) => const {
    UiKind.image,
    UiKind.button,
    UiKind.textField,
    UiKind.checkbox,
    UiKind.radio,
    UiKind.slider,
    UiKind.select,
  }.contains(n.kind);

  bool _isBlockLevel(dom.Element el, ComputedStyle s) {
    if (_blockLevelDisplays.contains(s.display)) return true;
    if (s.display == 'inline' &&
        !_atomicTags.contains(el.localName) &&
        _containsBlock(el)) {
      return true;
    }
    return false;
  }

  bool _isAtomicInline(dom.Element el, ComputedStyle s) {
    final tag = el.localName;
    if (_atomicTags.contains(tag) || _unsupportedReplaced.contains(tag)) {
      return true;
    }
    if (s.display != 'inline') return true;
    return _needsBox(s) || _containsBlock(el);
  }

  _FlowItem? _runItem(List<dom.Node> nodes, ComputedStyle ps) {
    final raw = <_Raw>[];
    _collect(nodes, ps, raw);
    final spans = _normalize(raw);
    if (spans.isEmpty) return null;
    if (spans.length == 1 && spans[0].widget != null) {
      return _FlowItem(spans[0].widget!, atomic: true);
    }
    final n = UiNode(UiKind.text, tag: '#text');
    n.spans = spans;
    n.textStyle = mapper.textStyle(ps);
    n.textAlign = mapper.textAlign(ps);
    final ws = (ps['white-space'] ?? 'normal').toLowerCase();
    n.softWrap = ws != 'nowrap';
    if ((ps['text-overflow'] ?? '').toLowerCase() == 'ellipsis') {
      n.ellipsis = true;
      if (ws == 'nowrap') n.maxLines = 1;
    }
    return _FlowItem(n, isRun: true);
  }

  void _collect(Iterable<dom.Node> nodes, ComputedStyle ps, List<_Raw> out) {
    for (final n in nodes) {
      if (n is dom.Text) {
        final ws = (ps['white-space'] ?? 'normal').toLowerCase();
        out.add(
          _Raw.text(
            mapper.transformText(n.data, ps),
            mapper.textStyle(ps),
            pre: ws == 'pre' || ws == 'pre-wrap' || ws == 'pre-line',
          ),
        );
      } else if (n is dom.Element) {
        if (n.localName == 'br') {
          out.add(_Raw.br(mapper.textStyle(ps)));
          continue;
        }
        final cs = _style(n, ps);
        if (cs.display == 'none') continue;
        if (_isAtomicInline(n, cs)) {
          final node = _blockNode(n, cs);
          if (node != null) out.add(_Raw.widget(node));
        } else {
          _collect(n.nodes, cs, out);
        }
      }
    }
  }

  /// Collapses whitespace like a browser and merges adjacent equal spans.
  List<UiSpan> _normalize(List<_Raw> raw) {
    final out = <_Raw>[];
    var prevSpace = true;
    final ws = RegExp(r'[ \t\r\n\f]+');
    for (final r in raw) {
      if (r.widget != null) {
        out.add(r);
        prevSpace = false;
        continue;
      }
      if (r.isBreak) {
        if (out.isNotEmpty &&
            out.last.widget == null &&
            !out.last.pre &&
            out.last.text.endsWith(' ')) {
          out.last.text = out.last.text.substring(0, out.last.text.length - 1);
        }
        out.add(_Raw.text('\n', r.style));
        prevSpace = true;
        continue;
      }
      var t = r.pre ? r.text : r.text.replaceAll(ws, ' ');
      if (!r.pre && prevSpace && t.startsWith(' ')) t = t.substring(1);
      if (t.isEmpty) continue;
      prevSpace = !r.pre && t.endsWith(' ');
      out.add(_Raw.text(t, r.style, pre: r.pre));
    }
    // Trim the trailing space / single trailing line break.
    while (out.isNotEmpty && out.last.widget == null && out.last.text.isEmpty) {
      out.removeLast();
    }
    if (out.isNotEmpty && out.last.widget == null) {
      final last = out.last;
      if (!last.pre && last.text.endsWith(' ')) {
        last.text = last.text.substring(0, last.text.length - 1);
      }
      if (last.text == '\n') out.removeLast();
    }
    while (out.isNotEmpty && out.last.widget == null && out.last.text.isEmpty) {
      out.removeLast();
    }

    final spans = <UiSpan>[];
    for (final r in out) {
      if (r.widget != null) {
        spans.add(UiSpan.widget(r.widget!));
        continue;
      }
      if (r.text.isEmpty) continue;
      if (spans.isNotEmpty &&
          spans.last.widget == null &&
          spans.last.style == r.style) {
        spans[spans.length - 1] = UiSpan.text(
          spans.last.text! + r.text,
          r.style,
        );
      } else {
        spans.add(UiSpan.text(r.text, r.style));
      }
    }
    // A run consisting only of whitespace characters produces nothing.
    if (spans.every(
      (s) =>
          s.widget == null && s.text!.trim().isEmpty && !s.text!.contains('\n'),
    )) {
      return const [];
    }
    return spans;
  }

  // ------------------------------------------------------ placement logic

  /// Prepares [n] to be a child of a stretching block column.
  void _placeInBlock(
    UiNode n, {
    required bool atomic,
    required UiTextAlign textAlign,
  }) {
    final b = n.box;
    final fill = b.width != null && b.width!.isPercent && b.width!.value >= 100;
    if (b.width != null && b.width!.isPercent) {
      if (b.width!.value < 100) n.widthFactor = b.width!.value / 100;
      n.box = b.copyWith(clearWidth: true);
    }
    final constrained =
        n.widthFactor != null ||
        n.box.width != null ||
        b.maxWidth != null ||
        b.minWidth != null;
    final shrinks = (atomic || _isAtomicKind(n)) && !fill;
    if (shrinks) {
      if (n.kind == UiKind.column) n.crossAxis = UiCross.start;
      if (n.kind == UiKind.row) n.shrinkWrap = true;
    }
    if (!constrained && !shrinks) return;

    double x = -1;
    if (b.marginLeftAuto && b.marginRightAuto) {
      x = 0;
    } else if (b.marginLeftAuto) {
      x = 1;
    } else if (b.marginRightAuto) {
      x = -1;
    } else if (shrinks) {
      x = textAlign == UiTextAlign.center
          ? 0
          : textAlign == UiTextAlign.right
          ? 1
          : -1;
    }
    n.alignX = x;
    n.alignY = -1;
  }

  /// Sibling margin collapsing for block flow (adjoining vertical margins
  /// take the larger value instead of adding up).
  void _collapseSiblingMargins(List<UiNode> kids) {
    for (var i = 1; i < kids.length; i++) {
      final prev = kids[i - 1], next = kids[i];
      final a = prev.box.margin.bottom, b = next.box.margin.top;
      if (a > 0 && b > 0) {
        next.box = next.box.copyWith(
          margin: next.box.margin.copyWith(top: math.max(0, b - a)),
        );
      }
    }
  }

  /// Lets the first/last child's margin escape a parent that has no padding
  /// or border (as browsers do).
  void _collapseParentMargins(UiNode col) {
    if (col.children.isEmpty || col.box.clip) return;
    final b = col.box;
    var margin = b.margin;
    final first = col.children.first, last = col.children.last;
    if (b.padding.top == 0 &&
        b.border?.top == null &&
        first.box.margin.top > 0) {
      margin = margin.copyWith(top: math.max(margin.top, first.box.margin.top));
      first.box = first.box.copyWith(margin: first.box.margin.copyWith(top: 0));
    }
    if (b.padding.bottom == 0 &&
        b.border?.bottom == null &&
        b.height == null &&
        b.minHeight == null &&
        last.box.margin.bottom > 0) {
      margin = margin.copyWith(
        bottom: math.max(margin.bottom, last.box.margin.bottom),
      );
      last.box = last.box.copyWith(margin: last.box.margin.copyWith(bottom: 0));
    }
    if (margin != b.margin) col.box = b.copyWith(margin: margin);
  }

  // ---------------------------------------------------------------- flex

  UiMain _mainOf(String? v) {
    switch (v?.toLowerCase()) {
      case 'flex-end':
      case 'end':
      case 'right':
        return UiMain.end;
      case 'center':
        return UiMain.center;
      case 'space-between':
        return UiMain.spaceBetween;
      case 'space-around':
        return UiMain.spaceAround;
      case 'space-evenly':
        return UiMain.spaceEvenly;
    }
    return UiMain.start;
  }

  UiCross _crossOf(String? v) {
    switch (v?.toLowerCase()) {
      case 'flex-start':
      case 'start':
      case 'self-start':
      case 'baseline':
      case 'first baseline':
      case 'left':
        return UiCross.start;
      case 'flex-end':
      case 'end':
      case 'self-end':
      case 'right':
        return UiCross.end;
      case 'center':
        return UiCross.center;
    }
    return UiCross.stretch;
  }

  double? _alignSelf(String? v) {
    switch (v?.toLowerCase()) {
      case 'flex-start':
      case 'start':
      case 'self-start':
        return -1;
      case 'center':
        return 0;
      case 'flex-end':
      case 'end':
      case 'self-end':
        return 1;
    }
    return null;
  }

  double _gapOf(ComputedStyle s, String prop) {
    final v = s[prop];
    if (v == null || v.toLowerCase() == 'normal') return 0;
    final px = parsePx(v, fontSize: s.fontSize);
    if (px == null) {
      warnings.add(
        'gap:$prop',
        'Unsupported value "$v" for "$prop" was ignored',
        feature: prop,
      );
      return 0;
    }
    return px;
  }

  List<(UiNode, ComputedStyle?)> _flexItems(dom.Element el, ComputedStyle s) {
    final items = <(UiNode, ComputedStyle?)>[];
    for (final n in el.nodes) {
      if (n is dom.Text) {
        final item = _runItem([n], s);
        if (item != null) items.add((item.node, null));
      } else if (n is dom.Element) {
        if (n.localName == 'br') continue;
        final cs = _style(n, s);
        if (cs.display == 'none') continue;
        final node = _blockNode(n, cs);
        if (node != null) items.add((node, cs));
      }
    }
    return items;
  }

  UiNode _spacer({int flex = 1}) {
    final n = UiNode(UiKind.column, tag: 'spacer');
    n.flex = flex;
    n.flexTight = true;
    return n;
  }

  UiNode _flex(dom.Element el, ComputedStyle s) {
    final tag = el.localName!;
    final box = mapper.box(s, tag: tag);
    final dir = (s['flex-direction'] ?? 'row').toLowerCase();
    final isRow = dir.startsWith('row');
    final reverse = dir.endsWith('reverse');
    final wrap = (s['flex-wrap'] ?? 'nowrap').toLowerCase().startsWith('wrap');

    var items = _flexItems(el, s);
    if (reverse) items = items.reversed.toList();

    var main = _mainOf(s['justify-content']);
    if (reverse) {
      main = main == UiMain.start
          ? UiMain.end
          : main == UiMain.end
          ? UiMain.start
          : main;
    }
    final cross = _crossOf(s['align-items']);

    final kind = isRow ? (wrap ? UiKind.wrap : UiKind.row) : UiKind.column;
    if (!isRow && wrap) {
      warnings.add(
        'flex:column-wrap',
        'flex-wrap on a column container is not supported; items are not wrapped',
        feature: 'flex-wrap (column)',
      );
    }
    final node = UiNode(kind, tag: tag, label: _label(el), box: box);
    node.mainAxis = main;
    node.shrinkWrap = s.display == 'inline-flex';
    final colGap = _gapOf(s, 'column-gap'), rowGap = _gapOf(s, 'row-gap');
    node.gap = isRow ? colGap : rowGap;
    node.runGap = isRow ? rowGap : colGap;

    final definiteHeight = box.height != null && box.height!.isPx;
    final children = <UiNode>[];

    for (final (child, cs) in items) {
      final cb = child.box;
      if (isRow && !wrap && cb.marginLeftAuto && !cb.marginRightAuto) {
        children.add(_spacer());
      }
      if (isRow && !wrap && cb.marginLeftAuto && cb.marginRightAuto) {
        children.add(_spacer());
      }
      if (cs != null) {
        if (isRow) {
          wrap ? _placeInWrap(child, cs) : _placeInRow(child, cs);
        } else {
          _placeInFlexColumn(
            child,
            cs,
            stretch: cross == UiCross.stretch,
            definiteHeight: definiteHeight,
          );
        }
      }
      children.add(child);
      if (isRow && !wrap && cb.marginRightAuto) {
        children.add(_spacer());
      }
    }
    node.children = children;

    if (kind == UiKind.row) {
      final hasHeight = definiteHeight;
      final visualKids =
          children.length > 1 &&
          children.any((c) => c.box.isVisual || c.box.radius != null);
      if (cross == UiCross.stretch) {
        if (hasHeight) {
          node.crossAxis = UiCross.stretch;
        } else if (visualKids) {
          node.crossAxis = UiCross.stretch;
          node.intrinsicHeight = true;
        } else {
          node.crossAxis = UiCross.start;
        }
      } else {
        node.crossAxis = cross;
      }
    } else if (kind == UiKind.wrap) {
      node.crossAxis = cross == UiCross.stretch ? UiCross.start : cross;
    } else {
      node.crossAxis = cross;
    }
    return node;
  }

  bool _isFlexible(UiNode n) =>
      n.kind == UiKind.text ||
      n.kind == UiKind.column ||
      n.kind == UiKind.row ||
      n.kind == UiKind.wrap;

  void _placeInRow(UiNode child, ComputedStyle cs) {
    final grow = double.tryParse(cs['flex-grow'] ?? '') ?? 0;
    final shrink = double.tryParse(cs['flex-shrink'] ?? '') ?? 1;
    final basis = cs['flex-basis'];
    var b = child.box;
    if (basis != null && b.width == null) {
      final px = parsePx(basis, fontSize: cs.fontSize);
      if (px != null && px > 0) {
        child.box = b = b.copyWith(width: UiLen(px));
      }
    }
    if (grow > 0) {
      child.flex = math.max(1, grow.round());
      child.flexTight = true;
      child.box = b.copyWith(clearWidth: true);
    } else if (b.width != null && b.width!.isPercent) {
      child.flex = math.max(1, b.width!.value.round());
      child.flexTight = true;
      child.box = b.copyWith(clearWidth: true);
    } else if (b.width == null && _isFlexible(child) && shrink != 0) {
      child.flex = 1;
      child.flexTight = false;
      if (child.kind == UiKind.row) child.shrinkWrap = true;
      if (child.kind == UiKind.column) child.crossAxis = UiCross.start;
    }
    final a = _alignSelf(cs['align-self']);
    if (a != null) {
      child.alignX = -1;
      child.alignY = a;
    }
  }

  void _placeInWrap(UiNode child, ComputedStyle cs) {
    final b = child.box;
    if (b.width != null && b.width!.isPercent) {
      warnings.add(
        'wrap-percent',
        'Percentage widths inside wrapping flex containers are not supported',
        level: WarningLevel.info,
      );
      child.box = b.copyWith(clearWidth: true);
    }
    if (child.kind == UiKind.column) child.crossAxis = UiCross.start;
    if (child.kind == UiKind.row) child.shrinkWrap = true;
  }

  void _placeInFlexColumn(
    UiNode child,
    ComputedStyle cs, {
    required bool stretch,
    required bool definiteHeight,
  }) {
    final grow = double.tryParse(cs['flex-grow'] ?? '') ?? 0;
    if (grow > 0 && definiteHeight) {
      child.flex = math.max(1, grow.round());
      child.flexTight = true;
    }
    final self = _alignSelf(cs['align-self']);
    final b = child.box;
    if (b.width != null && b.width!.isPercent) {
      if (b.width!.value < 100) child.widthFactor = b.width!.value / 100;
      child.box = b.copyWith(clearWidth: true);
    }
    final constrained =
        child.widthFactor != null ||
        child.box.width != null ||
        b.maxWidth != null;
    if (self != null) {
      child.alignX = self;
      child.alignY = -1;
      if (child.kind == UiKind.column) child.crossAxis = UiCross.start;
    } else if (stretch && (constrained || _isAtomicKind(child))) {
      final fill =
          b.width != null && b.width!.isPercent && b.width!.value >= 100;
      if (!fill) {
        child.alignX = b.marginLeftAuto && b.marginRightAuto ? 0 : -1;
        child.alignY = -1;
      }
    }
  }

  // ---------------------------------------------------------------- grid

  List<_Track>? _parseTracks(String? v, double fs, List<double> autoMin) {
    if (v == null || v.toLowerCase() == 'none') return null;
    final tracks = <_Track>[];
    _Track one(String t) {
      final m = RegExp(r'^([\d.]+)fr$').firstMatch(t);
      if (m != null) {
        return _Track(flex: math.max(1, double.parse(m.group(1)!).round()));
      }
      final len = parseLen(t, fontSize: fs);
      if (len != null && len.isPx) return _Track(fixed: len.value);
      if (len != null && len.isPercent) {
        return _Track(flex: math.max(1, len.value.round()));
      }
      return _Track();
    }

    for (final t in splitTopLevel(v)) {
      final rep = RegExp(r'^repeat\((.*)\)$', dotAll: true).firstMatch(t);
      if (rep != null) {
        final args = splitCommas(rep.group(1)!);
        if (args.length < 2) continue;
        final countText = args[0].trim().toLowerCase();
        final n = int.tryParse(countText);
        final inner = args.sublist(1).join(',');
        if (n == null) {
          final mm = RegExp(r'minmax\(\s*([^,]+),').firstMatch(inner);
          final px = mm == null ? null : parsePx(mm.group(1)!, fontSize: fs);
          autoMin.add(px ?? 200);
          return null;
        }
        for (var i = 0; i < n.clamp(0, 24); i++) {
          for (final it in splitTopLevel(inner)) {
            tracks.add(one(it));
          }
        }
      } else {
        tracks.add(one(t));
      }
    }
    return tracks.isEmpty ? null : tracks;
  }

  UiNode _grid(dom.Element el, ComputedStyle s) {
    final tag = el.localName!;
    final box = mapper.box(s, tag: tag);
    final items = _flexItems(el, s);
    final colGap = _gapOf(s, 'column-gap'), rowGap = _gapOf(s, 'row-gap');
    final autoMin = <double>[];
    final tracks = _parseTracks(
      s['grid-template-columns'],
      s.fontSize,
      autoMin,
    );
    warnings.add(
      'grid',
      'CSS Grid is approximated with rows and columns; spans and areas are ignored',
      feature: 'display: grid',
    );

    if (autoMin.isNotEmpty) {
      final w = UiNode(UiKind.wrap, tag: tag, label: _label(el), box: box);
      w.gap = colGap;
      w.runGap = rowGap;
      w.crossAxis = UiCross.start;
      for (final (child, _) in items) {
        if (child.box.width == null) {
          child.box = child.box.copyWith(width: UiLen(autoMin.first));
        }
        w.children.add(child);
      }
      return w;
    }

    final col = UiNode(UiKind.column, tag: tag, label: _label(el), box: box);
    col.gap = rowGap;
    col.crossAxis = UiCross.stretch;
    if (tracks == null) {
      for (final (child, _) in items) {
        _placeInBlock(
          child,
          atomic: _isAtomicKind(child),
          textAlign: UiTextAlign.start,
        );
        col.children.add(child);
      }
      return col;
    }
    for (var i = 0; i < items.length; i += tracks.length) {
      final row = UiNode(UiKind.row, tag: 'row');
      row.gap = colGap;
      final cells = <UiNode>[];
      for (var c = 0; c < tracks.length; c++) {
        final idx = i + c;
        final t = tracks[c];
        UiNode cell;
        if (idx < items.length) {
          cell = items[idx].$1;
        } else {
          cell = _spacer();
        }
        if (t.fixed != null) {
          if (idx < items.length) {
            cell.box = cell.box.copyWith(width: UiLen(t.fixed!));
          }
        } else {
          cell.flex = t.flex;
          cell.flexTight = true;
          if (cell.box.width != null) {
            cell.box = cell.box.copyWith(clearWidth: true);
          }
        }
        cells.add(cell);
      }
      row.children = cells;
      _finishStretchRow(row);
      col.children.add(row);
    }
    return col;
  }

  void _finishStretchRow(UiNode row) {
    final visual =
        row.children.length > 1 &&
        row.children.any((c) => c.box.isVisual || c.box.radius != null);
    if (visual) {
      row.crossAxis = UiCross.stretch;
      row.intrinsicHeight = true;
    } else {
      row.crossAxis = UiCross.start;
    }
  }

  // --------------------------------------------------------------- table

  UiNode _table(dom.Element el, ComputedStyle s) {
    final tag = el.localName!;
    final box = mapper.box(s, tag: tag);
    final table = UiNode(UiKind.column, tag: tag, label: _label(el), box: box);
    table.crossAxis = UiCross.stretch;
    final collapse = (s['border-collapse'] ?? '').toLowerCase() == 'collapse';

    final rows = <dom.Element>[];
    dom.Element? caption;
    void walk(dom.Element e) {
      for (final c in e.children) {
        switch (c.localName) {
          case 'tr':
            rows.add(c);
          case 'thead':
          case 'tbody':
          case 'tfoot':
            walk(c);
          case 'caption':
            caption ??= c;
        }
      }
    }

    walk(el);
    if (caption != null) {
      final cs = _style(caption!, s);
      final n = _flowNode(caption!, cs);
      table.children.add(n);
    }

    final built = <(UiNode row, List<int> spans)>[];
    var maxCols = 0;
    for (var r = 0; r < rows.length; r++) {
      final tr = rows[r];
      final trStyle = _style(tr, s);
      if (trStyle.display == 'none') continue;
      final rowNode = UiNode(
        UiKind.row,
        tag: 'tr',
        label: _label(tr),
        box: mapper.box(trStyle, tag: 'tr'),
      );
      final spans = <int>[];
      var cellIndex = 0;
      for (final td in tr.children) {
        if (td.localName != 'td' && td.localName != 'th') continue;
        final cs = _style(td, trStyle);
        if (cs.display == 'none') continue;
        final cell = _flowNode(td, cs);
        final span = (int.tryParse(td.attributes['colspan'] ?? '') ?? 1).clamp(
          1,
          24,
        );
        if (collapse) {
          final bd = cell.box.border;
          if (bd != null && (cellIndex > 0 || built.isNotEmpty)) {
            final nb = bd.without(top: built.isNotEmpty, left: cellIndex > 0);
            cell.box = nb.isEmpty
                ? cell.box.copyWith(clearBorder: true)
                : cell.box.copyWith(border: nb);
          }
        }
        final w = cell.box.width;
        if (w != null && w.isPercent) {
          cell.flex = math.max(1, w.value.round());
          cell.flexTight = true;
          cell.box = cell.box.copyWith(clearWidth: true);
        } else if (w == null) {
          cell.flex = span;
          cell.flexTight = true;
        }
        spans.add(span);
        rowNode.children.add(cell);
        cellIndex++;
      }
      if (rowNode.children.isEmpty) continue;
      maxCols = math.max(maxCols, spans.fold<int>(0, (a, b) => a + b));
      built.add((rowNode, spans));
    }
    for (final (row, spans) in built) {
      final used = spans.fold<int>(0, (a, b) => a + b);
      if (used < maxCols) row.children.add(_spacer(flex: maxCols - used));
      row.crossAxis = UiCross.stretch;
      row.intrinsicHeight = row.children.length > 1;
      table.children.add(row);
    }
    return table;
  }

  // ---------------------------------------------------------------- lists

  String? _marker(String type, int index) {
    String alpha(int i, bool upper) {
      var n = i, s = '';
      while (n > 0) {
        n--;
        s = String.fromCharCode(97 + n % 26) + s;
        n ~/= 26;
      }
      return upper ? s.toUpperCase() : s;
    }

    String roman(int i, bool upper) {
      const map = [
        (1000, 'm'),
        (900, 'cm'),
        (500, 'd'),
        (400, 'cd'),
        (100, 'c'),
        (90, 'xc'),
        (50, 'l'),
        (40, 'xl'),
        (10, 'x'),
        (9, 'ix'),
        (5, 'v'),
        (4, 'iv'),
        (1, 'i'),
      ];
      var n = i, s = '';
      for (final (v, r) in map) {
        while (n >= v) {
          s += r;
          n -= v;
        }
      }
      return upper ? s.toUpperCase() : s;
    }

    switch (type) {
      case 'none':
        return null;
      case 'circle':
        return '◦';
      case 'square':
        return '▪';
      case 'decimal':
        return '$index.';
      case 'decimal-leading-zero':
        return '${index.toString().padLeft(2, '0')}.';
      case 'lower-alpha':
      case 'lower-latin':
        return '${alpha(index, false)}.';
      case 'upper-alpha':
      case 'upper-latin':
        return '${alpha(index, true)}.';
      case 'lower-roman':
        return '${roman(index, false)}.';
      case 'upper-roman':
        return '${roman(index, true)}.';
    }
    return '•';
  }

  UiNode _list(dom.Element el, ComputedStyle s) {
    const markerWidth = 24.0;
    final tag = el.localName!;
    var box = mapper.box(s, tag: tag);
    final type = (s['list-style-type'] ?? (tag == 'ol' ? 'decimal' : 'disc'))
        .toLowerCase();
    final col = UiNode(UiKind.column, tag: tag, label: _label(el));
    col.crossAxis = UiCross.stretch;

    var start = int.tryParse(el.attributes['start'] ?? '') ?? 1;
    var index = start;
    var anyMarker = false;
    for (final child in el.children) {
      final cs = _style(child, s);
      if (cs.display == 'none') continue;
      final node = _blockNode(child, cs);
      if (node == null) continue;
      if (child.localName == 'li') {
        final liType = (cs['list-style-type'] ?? type).toLowerCase();
        final m = _marker(liType, index);
        index++;
        if (m != null && cs.display == 'list-item') {
          anyMarker = true;
          final marker = UiNode(
            UiKind.text,
            tag: 'marker',
            box: const UiBox(
              width: UiLen(markerWidth),
              padding: UiInsets(0, 8, 0, 0),
            ),
          );
          marker.spans = [UiSpan.text(m, mapper.textStyle(cs))];
          marker.textStyle = mapper.textStyle(cs);
          marker.textAlign = UiTextAlign.right;
          node.flex = 1;
          node.flexTight = true;
          final row = UiNode(UiKind.row, tag: 'li', label: node.label);
          row.crossAxis = UiCross.start;
          row.children = [marker, node];
          // The row takes over the item's vertical margins.
          row.box = UiBox(
            margin: UiInsets(node.box.margin.top, 0, node.box.margin.bottom, 0),
          );
          node.box = node.box.copyWith(
            margin: node.box.margin.copyWith(top: 0, bottom: 0),
          );
          col.children.add(row);
          continue;
        }
      }
      _placeInBlock(
        node,
        atomic: _isAtomicKind(node),
        textAlign: UiTextAlign.start,
      );
      col.children.add(node);
    }
    if (anyMarker && box.padding.left > 0) {
      box = box.copyWith(
        padding: box.padding.copyWith(
          left: math.max(0, box.padding.left - markerWidth),
        ),
      );
    }
    col.box = box;
    _collapseSiblingMargins(col.children);
    _collapseParentMargins(col);
    return col;
  }

  // ---------------------------------------------------------------- atomic

  /// Strips visuals that Flutter controls render themselves.
  UiBox _controlBox(UiBox b) => UiBox(
    width: b.width,
    height: b.height,
    minWidth: b.minWidth,
    maxWidth: b.maxWidth,
    minHeight: b.minHeight,
    maxHeight: b.maxHeight,
    margin: b.margin,
    opacity: b.opacity,
    marginLeftAuto: b.marginLeftAuto,
    marginRightAuto: b.marginRightAuto,
  );

  UiNode _image(dom.Element el, ComputedStyle s) {
    final box = mapper.box(s, tag: 'img');
    final n = UiNode(UiKind.image, tag: 'img', label: _label(el), box: box);
    final src = el.attributes['src']?.trim() ?? '';
    n.src = src;
    n.alt = el.attributes['alt'];
    n.fit = mapper.objectFit(s);
    if (src.isEmpty) {
      warnings.add(
        'img:nosrc',
        '<img> without a src attribute shows a placeholder',
      );
    } else if (!RegExp(r'^(https?:|data:|//)').hasMatch(src)) {
      warnings.add(
        'img:relative',
        'Relative image URLs cannot be resolved (e.g. "$src"); '
            'a placeholder is shown unless the URL is absolute',
        level: WarningLevel.info,
      );
    }
    return n;
  }

  UiNode? _input(dom.Element el, ComputedStyle s) {
    final type = (el.attributes['type'] ?? 'text').toLowerCase();
    switch (type) {
      case 'hidden':
        return null;
      case 'checkbox':
      case 'radio':
        final n = UiNode(
          type == 'radio' ? UiKind.radio : UiKind.checkbox,
          tag: 'input',
          label: _label(el),
          box: _controlBox(mapper.box(s, tag: 'input')),
        );
        n.checked = el.attributes.containsKey('checked');
        n.group = el.attributes['name'] ?? '';
        n.id = ++_controlId;
        n.box = n.box.copyWith(clearWidth: true, clearHeight: true);
        return n;
      case 'range':
        final n = UiNode(
          UiKind.slider,
          tag: 'input',
          label: _label(el),
          box: _controlBox(mapper.box(s, tag: 'input')),
        );
        final min = double.tryParse(el.attributes['min'] ?? '') ?? 0;
        final max = double.tryParse(el.attributes['max'] ?? '') ?? 100;
        final v =
            double.tryParse(el.attributes['value'] ?? '') ?? (min + max) / 2;
        n.value = max > min
            ? round3(((v - min) / (max - min)).clamp(0, 1)).toString()
            : '0.5';
        return n;
      case 'submit':
      case 'button':
      case 'reset':
      case 'image':
        final label =
            el.attributes['value'] ??
            (type == 'submit'
                ? 'Submit'
                : type == 'reset'
                ? 'Reset'
                : '');
        return _button(el, s, label);
    }
    final n = UiNode(UiKind.textField, tag: 'input', label: _label(el));
    final full = mapper.box(s, tag: 'input');
    n.box = _controlBox(full);
    n.control = mapper.control(full);
    n.textStyle = mapper.textStyle(s);
    n.hint = el.attributes['placeholder'];
    n.value = el.attributes['value'];
    n.obscure = type == 'password';
    if (!const {
      'text',
      'email',
      'password',
      'search',
      'tel',
      'url',
      'number',
    }.contains(type)) {
      warnings.add(
        'input:$type',
        'input type="$type" is approximated with a plain text field',
        level: WarningLevel.info,
      );
    }
    return n;
  }

  String _buttonLabel(dom.Element el, ComputedStyle s) {
    final t = mapper.transformText(
      el.text.replaceAll(RegExp(r'[ \t\r\n\f]+'), ' ').trim(),
      s,
    );
    if (el.children.isNotEmpty) {
      warnings.add(
        'button:children',
        'Only the text of <button> elements is converted; nested markup is dropped',
        level: WarningLevel.info,
      );
    }
    return t;
  }

  UiNode _button(dom.Element el, ComputedStyle s, String label) {
    final full = mapper.box(s, tag: 'button');
    final n = UiNode(UiKind.button, tag: 'button', label: _label(el));
    n.box = _controlBox(full);
    n.control = mapper.control(full);
    n.textStyle = mapper.textStyle(s);
    n.value = mapper.transformText(label, s);
    return n;
  }

  UiNode _textarea(dom.Element el, ComputedStyle s) {
    final full = mapper.box(s, tag: 'textarea');
    final n = UiNode(UiKind.textField, tag: 'textarea', label: _label(el));
    n.box = _controlBox(full);
    n.control = mapper.control(full);
    n.textStyle = mapper.textStyle(s);
    n.hint = el.attributes['placeholder'];
    var text = el.text;
    if (text.startsWith('\n')) text = text.substring(1);
    n.value = text.isEmpty ? null : text;
    n.lines = full.height != null
        ? 0
        : (int.tryParse(el.attributes['rows'] ?? '') ?? 2);
    return n;
  }

  UiNode _select(dom.Element el, ComputedStyle s) {
    final full = mapper.box(s, tag: 'select');
    final n = UiNode(UiKind.select, tag: 'select', label: _label(el));
    n.box = _controlBox(full);
    n.control = mapper.control(full);
    n.textStyle = mapper.textStyle(s);
    final options = el.querySelectorAll('option');
    n.options = [
      for (final o in options) o.text.replaceAll(RegExp(r'\s+'), ' ').trim(),
    ];
    var selected = options.isEmpty ? null : options.first;
    for (final o in options) {
      if (o.attributes.containsKey('selected')) selected = o;
    }
    n.selectedIndex = selected == null ? 0 : options.indexOf(selected);
    n.value = selected?.text.replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';
    return n;
  }

  UiNode _divider(dom.Element el, ComputedStyle s) {
    final full = mapper.box(s, tag: 'hr');
    final n = UiNode(UiKind.divider, tag: 'hr', label: _label(el));
    n.box = UiBox(
      margin: full.margin,
      opacity: full.opacity,
      marginLeftAuto: full.marginLeftAuto,
      marginRightAuto: full.marginRightAuto,
      width: full.width,
      maxWidth: full.maxWidth,
    );
    final top = full.border?.top ?? full.border?.bottom;
    final h = full.height;
    if (h != null && h.isPx && full.background != null) {
      n.dividerThickness = math.max(
        1,
        h.value - (full.border?.verticalWidth ?? 0),
      );
      n.dividerColor = full.background!;
    } else if (top != null) {
      n.dividerThickness = top.width;
      n.dividerColor = top.color;
    } else if (full.background != null) {
      n.dividerColor = full.background!;
    }
    return n;
  }
}
