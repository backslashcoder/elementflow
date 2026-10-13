import 'dart:math' as math;

import '../models/conversion_result.dart';
import '../models/ui_node.dart';
import '../models/ui_style.dart';
import 'css_values.dart';
import 'style_resolver.dart';
import 'warning_collector.dart';

/// Converts resolved CSS ([ComputedStyle]) into IR style objects.
class StyleMapper {
  StyleMapper(this._warnings);

  final WarningCollector _warnings;

  static const _genericFamilies = {
    'serif',
    'sans-serif',
    'cursive',
    'fantasy',
    'system-ui',
    'ui-sans-serif',
    'ui-serif',
    'ui-rounded',
    'ui-monospace',
    '-apple-system',
    'blinkmacsystemfont',
    'inherit',
    'initial',
  };

  void _bad(String prop, String value) => _warnings.add(
    'value:$prop',
    'Unsupported value "$value" for "$prop" was ignored',
    feature: prop,
  );

  // ---------------------------------------------------------------- text

  UiTextStyle textStyle(ComputedStyle s) {
    final lines = (s['text-decoration-line'] ?? '').toLowerCase();
    final lh = double.tryParse(s['line-height'] ?? '');
    final ls = parsePx(s['letter-spacing'] ?? '', fontSize: s.fontSize);
    return UiTextStyle(
      color: s.color,
      fontSize: s.fontSize,
      weight: int.tryParse(s['font-weight'] ?? '') ?? 400,
      italic: const {
        'italic',
        'oblique',
      }.contains(s['font-style']?.toLowerCase()),
      underline: lines.contains('underline'),
      lineThrough: lines.contains('line-through'),
      overline: lines.contains('overline'),
      fontFamily: _family(s['font-family']),
      height: lh != null && lh > 0 ? round3(lh) : null,
      letterSpacing: ls != null && ls != 0 ? ls : null,
    );
  }

  String? _family(String? raw) {
    if (raw == null) return null;
    var sawMono = false;
    for (final f in splitCommas(raw)) {
      final name = stripQuotes(f);
      final lower = name.toLowerCase();
      if (lower == 'monospace') {
        sawMono = true;
      } else if (!_genericFamilies.contains(lower) && name.isNotEmpty) {
        return name;
      }
    }
    return sawMono ? 'monospace' : null;
  }

  UiTextAlign textAlign(ComputedStyle s) {
    switch (s['text-align']?.toLowerCase()) {
      case 'center':
        return UiTextAlign.center;
      case 'right':
      case 'end':
        return UiTextAlign.right;
      case 'justify':
        return UiTextAlign.justify;
      case 'left':
        return UiTextAlign.left;
    }
    return UiTextAlign.start;
  }

  String transformText(String text, ComputedStyle s) {
    switch (s['text-transform']?.toLowerCase()) {
      case 'uppercase':
        return text.toUpperCase();
      case 'lowercase':
        return text.toLowerCase();
      case 'capitalize':
        return text.replaceAllMapped(
          RegExp(r'(^|\s)(\S)'),
          (m) => '${m.group(1)}${m.group(2)!.toUpperCase()}',
        );
    }
    return text;
  }

  // ----------------------------------------------------------------- box

  UiLen? _length(
    ComputedStyle s,
    String prop, {
    bool silentPercent = false,
    bool percentOk = true,
  }) {
    final v = s[prop];
    if (v == null) return null;
    final t = v.toLowerCase();
    if (t == 'auto' || t == 'none' || t == 'normal' || t == 'initial') {
      return null;
    }
    if (t == 'max-content' || t == 'min-content' || t == 'fit-content') {
      _warnings.add(
        'value:$prop:$t',
        'Intrinsic sizing keyword "$t" for "$prop" was ignored',
        level: WarningLevel.info,
      );
      return null;
    }
    final len = parseLen(t, fontSize: s.fontSize);
    if (len == null) {
      _bad(prop, v);
      return null;
    }
    if (len.isPercent && !percentOk) {
      if (!silentPercent) {
        _warnings.add(
          'percent:$prop',
          'Percentage values for "$prop" are not supported and were ignored',
          level: WarningLevel.info,
        );
      }
      return null;
    }
    return len;
  }

  double _space(ComputedStyle s, String prop) {
    final v = s[prop];
    if (v == null) return 0;
    final t = v.toLowerCase();
    if (t == 'auto') return 0;
    final len = parseLen(t, fontSize: s.fontSize);
    if (len == null || !len.isPx) {
      _warnings.add(
        'space:$prop',
        'Value "$v" for "$prop" is not supported and was treated as 0',
        feature: prop,
      );
      return 0;
    }
    if (len.value < 0) {
      _warnings.add(
        'negative:$prop',
        'Negative values for "$prop" are not supported and were set to 0',
        level: WarningLevel.info,
      );
      return 0;
    }
    return len.value;
  }

  UiBox box(ComputedStyle s, {required String tag}) {
    final isRoot = tag == 'html' || tag == 'body';
    final padding = UiInsets(
      _space(s, 'padding-top'),
      _space(s, 'padding-right'),
      _space(s, 'padding-bottom'),
      _space(s, 'padding-left'),
    );
    final margin = UiInsets(
      _space(s, 'margin-top'),
      _space(s, 'margin-right'),
      _space(s, 'margin-bottom'),
      _space(s, 'margin-left'),
    );
    final border = _border(s);

    var width = _length(s, 'width');
    var height = _length(s, 'height', silentPercent: isRoot, percentOk: false);
    var minWidth = _length(
      s,
      'min-width',
      percentOk: false,
      silentPercent: true,
    );
    var maxWidth = _length(
      s,
      'max-width',
      percentOk: false,
      silentPercent: true,
    );
    var minHeight = _length(
      s,
      'min-height',
      percentOk: false,
      silentPercent: isRoot,
    );
    var maxHeight = _length(s, 'max-height', percentOk: false);

    if (s['box-sizing']?.toLowerCase() != 'border-box') {
      final dx = padding.horizontal + (border?.horizontalWidth ?? 0);
      final dy = padding.vertical + (border?.verticalWidth ?? 0);
      width = width?.plus(dx);
      minWidth = minWidth?.plus(dx);
      maxWidth = maxWidth?.plus(dx);
      height = height?.plus(dy);
      minHeight = minHeight?.plus(dy);
      maxHeight = maxHeight?.plus(dy);
    }

    var background = backgroundColor(s);
    final gradient = _gradient(s);
    final overflow = '${s['overflow-x'] ?? ''} ${s['overflow-y'] ?? ''}';
    final clips = RegExp(r'hidden|clip|auto|scroll').hasMatch(overflow);
    if (RegExp(r'auto|scroll').hasMatch(overflow)) {
      _warnings.add(
        'overflow-scroll',
        'Scrolling containers (overflow: auto/scroll) are not supported; '
            'their content is clipped instead',
        level: WarningLevel.info,
      );
    }

    var opacity = double.tryParse(s['opacity'] ?? '') ?? 1;
    if ((s['visibility'] ?? '') == 'hidden') opacity = 0;

    var radius = _radius(s, width);
    if (radius != null && border != null && !border.isUniform) {
      // Flutter cannot draw rounded corners on borders with differing sides.
      _warnings.add(
        'border-radius:non-uniform',
        'border-radius combined with borders that differ per side is not '
            'supported; the radius was dropped on those elements',
        feature: 'border-radius with per-side borders',
      );
      radius = null;
    }

    return UiBox(
      width: width,
      height: height,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      padding: padding,
      margin: margin,
      background: background,
      gradient: gradient,
      border: border,
      radius: radius,
      shadows: _shadows(s),
      opacity: opacity.clamp(0, 1).toDouble(),
      clip: clips,
      marginLeftAuto: (s['margin-left'] ?? '').toLowerCase() == 'auto',
      marginRightAuto: (s['margin-right'] ?? '').toLowerCase() == 'auto',
    );
  }

  int? backgroundColor(ComputedStyle s) {
    final v = s['background-color'];
    if (v == null) return null;
    final c = parseColor(v, currentColor: s.color);
    if (c == null) {
      _warnings.add('color:$v', 'Invalid color value "$v" was ignored');
      return null;
    }
    return (c >> 24) == 0 ? null : c;
  }

  UiGradient? _gradient(ComputedStyle s) {
    final v = s['background-image'];
    if (v == null || v.toLowerCase() == 'none') return null;
    final lower = v.toLowerCase();
    if (lower.startsWith('linear-gradient(')) {
      final g = parseLinearGradient(
        v,
        fontSize: s.fontSize,
        currentColor: s.color,
      );
      if (g == null) {
        _warnings.add(
          'gradient:invalid',
          'A linear-gradient could not be parsed and was ignored',
          feature: 'linear-gradient',
        );
      }
      return g;
    }
    if (lower.startsWith('url(')) {
      _warnings.add(
        'background-image:url',
        'Background images (url()) are not supported and were ignored',
        feature: 'background-image',
      );
    } else {
      _warnings.add(
        'gradient:other',
        'Only linear gradients are supported; other gradient types were ignored',
        feature: 'gradient',
      );
    }
    return null;
  }

  UiBorder? _border(ComputedStyle s) {
    UiBorderSide? side(String name) {
      final style = (s['border-$name-style'] ?? 'none').toLowerCase();
      if (style == 'none' || style == 'hidden') return null;
      final w = (s['border-$name-width'] ?? 'medium').toLowerCase();
      double? width;
      switch (w) {
        case 'thin':
          width = 1;
        case 'medium':
          width = 3;
        case 'thick':
          width = 5;
        default:
          width = parsePx(w, fontSize: s.fontSize);
      }
      if (width == null) {
        _bad('border-$name-width', w);
        return null;
      }
      if (width <= 0) return null;
      if (style != 'solid') {
        _warnings.add(
          'border-style:$style',
          'Border style "$style" is not supported; drawn as solid',
          feature: 'border-style: $style',
        );
      }
      final cv = s['border-$name-color'] ?? 'currentcolor';
      var color = parseColor(cv, currentColor: s.color);
      if (color == null) {
        _warnings.add('color:$cv', 'Invalid color value "$cv" was ignored');
        color = s.color;
      }
      return UiBorderSide(width, color);
    }

    final b = UiBorder(
      top: side('top'),
      right: side('right'),
      bottom: side('bottom'),
      left: side('left'),
    );
    return b.isEmpty ? null : b;
  }

  UiRadius? _radius(ComputedStyle s, UiLen? width) {
    double corner(String prop) {
      final v = s[prop];
      if (v == null) return 0;
      final first = splitTopLevel(v).first;
      final len = parseLen(first, fontSize: s.fontSize);
      if (len == null) {
        _bad(prop, v);
        return 0;
      }
      if (len.isPx) return math.max(0, len.value);
      if (len.isPercent) {
        if (len.value >= 50) return 9999;
        if (width != null && width.isPx) {
          return round3(width.value * len.value / 100);
        }
        _warnings.add(
          'radius:percent',
          'Percentage border-radius below 50% needs a fixed width; it was ignored',
          feature: 'border-radius: %',
        );
      }
      return 0;
    }

    final r = UiRadius(
      corner('border-top-left-radius'),
      corner('border-top-right-radius'),
      corner('border-bottom-right-radius'),
      corner('border-bottom-left-radius'),
    );
    return r.isZero ? null : r;
  }

  List<UiShadow> _shadows(ComputedStyle s) {
    final v = s['box-shadow'];
    if (v == null) return const [];
    final r = parseBoxShadow(v, fontSize: s.fontSize, currentColor: s.color);
    if (r.hadInset) {
      _warnings.add(
        'shadow:inset',
        'Inset box shadows are not supported',
        feature: 'box-shadow: inset',
      );
    }
    if (r.hadInvalid) _bad('box-shadow', v);
    return r.shadows;
  }

  UiFit objectFit(ComputedStyle s) {
    switch (s['object-fit']?.toLowerCase()) {
      case 'cover':
        return UiFit.cover;
      case 'contain':
        return UiFit.contain;
      case 'none':
        return UiFit.none;
      case 'scale-down':
        return UiFit.scaleDown;
    }
    return UiFit.fill;
  }

  /// Visual style for controls, taken from the box before it is stripped.
  UiControlStyle control(UiBox b) {
    UiBorderSide? side;
    final bd = b.border;
    if (bd != null) side = bd.top ?? bd.left ?? bd.bottom ?? bd.right;
    int? fill = b.background;
    if (fill == null && b.gradient != null) {
      fill = b.gradient!.colors.first;
      _warnings.add(
        'control-gradient',
        'Gradients on buttons and inputs are approximated with their first color',
        feature: 'control gradient',
      );
    }
    final r = b.radius;
    return UiControlStyle(
      fill: fill,
      border: side,
      radius: r == null
          ? 0
          : math.max(
              math.max(r.topLeft, r.topRight),
              math.max(r.bottomLeft, r.bottomRight),
            ),
      padding: b.padding,
      hasShadow: b.shadows.isNotEmpty,
    );
  }
}
