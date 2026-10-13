import 'dart:math' as math;

import '../models/ui_style.dart';

/// Splits [input] on [separator] characters that are not nested inside
/// parentheses or quotes. Empty parts are dropped.
List<String> splitTopLevel(String input, {bool commas = false}) {
  final parts = <String>[];
  final buf = StringBuffer();
  var depth = 0;
  String? quote;
  for (var i = 0; i < input.length; i++) {
    final c = input[i];
    if (quote != null) {
      buf.write(c);
      if (c == quote) quote = null;
      continue;
    }
    if (c == '"' || c == "'") {
      quote = c;
      buf.write(c);
    } else if (c == '(') {
      depth++;
      buf.write(c);
    } else if (c == ')') {
      depth = math.max(0, depth - 1);
      buf.write(c);
    } else if (depth == 0 &&
        (commas
            ? c == ','
            : (c == ' ' || c == '\t' || c == '\n' || c == '\r'))) {
      if (buf.isNotEmpty) parts.add(buf.toString().trim());
      buf.clear();
    } else {
      buf.write(c);
    }
  }
  if (buf.toString().trim().isNotEmpty) parts.add(buf.toString().trim());
  return parts;
}

List<String> splitCommas(String input) => splitTopLevel(input, commas: true);

String stripQuotes(String s) {
  final t = s.trim();
  if (t.length >= 2 &&
      ((t.startsWith('"') && t.endsWith('"')) ||
          (t.startsWith("'") && t.endsWith("'")))) {
    return t.substring(1, t.length - 1);
  }
  return t;
}

double round3(double v) => (v * 1000).round() / 1000;

// ---------------------------------------------------------------------------
// Colors
// ---------------------------------------------------------------------------

/// Parses a CSS color. Returns an ARGB int, or null when invalid.
/// `transparent` yields 0x00000000.
int? parseColor(String input, {int? currentColor}) {
  final s = input.trim().toLowerCase();
  if (s.isEmpty) return null;
  if (s == 'transparent') return 0x00000000;
  if (s == 'currentcolor') return currentColor;
  if (s.startsWith('#')) return _parseHex(s.substring(1));
  final fn = RegExp(r'^(rgba?|hsla?)\((.*)\)$').firstMatch(s);
  if (fn != null) return _parseColorFunction(fn.group(1)!, fn.group(2)!);
  return _namedColors[s];
}

int? _parseHex(String h) {
  if (!RegExp(r'^[0-9a-f]+$').hasMatch(h)) return null;
  switch (h.length) {
    case 3:
    case 4:
      final d = h.split('').map((c) => c + c).join();
      return _parseHex(d);
    case 6:
      return 0xFF000000 | int.parse(h, radix: 16);
    case 8:
      final rgb = int.parse(h.substring(0, 6), radix: 16);
      final a = int.parse(h.substring(6), radix: 16);
      return (a << 24) | rgb;
  }
  return null;
}

int? _parseColorFunction(String name, String args) {
  final parts = args
      .replaceAll('/', ' ')
      .split(RegExp(r'[,\s]+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.length < 3) return null;
  double? alpha;
  if (parts.length >= 4) {
    alpha = _parseAlpha(parts[3]);
    if (alpha == null) return null;
  }
  final a = ((alpha ?? 1).clamp(0, 1) * 255).round();
  if (name.startsWith('rgb')) {
    final ch = <int>[];
    for (final p in parts.take(3)) {
      final v = p.endsWith('%')
          ? (double.tryParse(p.substring(0, p.length - 1)) ?? double.nan) * 2.55
          : double.tryParse(p) ?? double.nan;
      if (v.isNaN) return null;
      ch.add(v.round().clamp(0, 255));
    }
    return (a << 24) | (ch[0] << 16) | (ch[1] << 8) | ch[2];
  }
  // hsl
  final h = double.tryParse(parts[0].replaceAll('deg', ''));
  final sat = double.tryParse(parts[1].replaceAll('%', ''));
  final lig = double.tryParse(parts[2].replaceAll('%', ''));
  if (h == null || sat == null || lig == null) return null;
  final rgb = _hslToRgb(((h % 360) + 360) % 360, sat / 100, lig / 100);
  return (a << 24) | (rgb[0] << 16) | (rgb[1] << 8) | rgb[2];
}

double? _parseAlpha(String p) {
  if (p.endsWith('%')) {
    final v = double.tryParse(p.substring(0, p.length - 1));
    return v == null ? null : v / 100;
  }
  return double.tryParse(p);
}

List<int> _hslToRgb(double h, double s, double l) {
  final c = (1 - (2 * l - 1).abs()) * s;
  final x = c * (1 - ((h / 60) % 2 - 1).abs());
  final m = l - c / 2;
  double r = 0, g = 0, b = 0;
  if (h < 60) {
    r = c;
    g = x;
  } else if (h < 120) {
    r = x;
    g = c;
  } else if (h < 180) {
    g = c;
    b = x;
  } else if (h < 240) {
    g = x;
    b = c;
  } else if (h < 300) {
    r = x;
    b = c;
  } else {
    r = c;
    b = x;
  }
  int f(double v) => ((v + m) * 255).round().clamp(0, 255);
  return [f(r), f(g), f(b)];
}

// ---------------------------------------------------------------------------
// Lengths
// ---------------------------------------------------------------------------

/// Parses a CSS length. [fontSize] is the em basis. Returns null for
/// unsupported values (calc(), auto, keywords...).
UiLen? parseLen(
  String input, {
  required double fontSize,
  double rootFontSize = 16,
}) {
  final s = input.trim().toLowerCase();
  final m = RegExp(r'^([+-]?(?:\d+\.?\d*|\.\d+)(?:e[+-]?\d+)?)([a-z%]*)$')
      .firstMatch(s);
  if (m == null) return null;
  final n = double.parse(m.group(1)!);
  switch (m.group(2)!) {
    case '':
      return n == 0 ? const UiLen(0) : null;
    case 'px':
      return UiLen(n);
    case 'em':
      return UiLen(round3(n * fontSize));
    case 'rem':
      return UiLen(round3(n * rootFontSize));
    case 'ex':
    case 'ch':
      return UiLen(round3(n * fontSize * 0.5));
    case 'pt':
      return UiLen(round3(n * 4 / 3));
    case 'pc':
      return UiLen(n * 16);
    case 'in':
      return UiLen(n * 96);
    case 'cm':
      return UiLen(round3(n * 96 / 2.54));
    case 'mm':
      return UiLen(round3(n * 96 / 25.4));
    case '%':
      return UiLen(n, UiUnit.percent);
    case 'vw':
      return UiLen(n, UiUnit.vw);
    case 'vh':
      return UiLen(n, UiUnit.vh);
  }
  return null;
}

/// Convenience for pixel-only lengths (percent/viewport units yield null).
double? parsePx(String input, {required double fontSize}) {
  final l = parseLen(input, fontSize: fontSize);
  return l != null && l.isPx ? l.value : null;
}

const fontSizeKeywords = <String, double>{
  'xx-small': 9,
  'x-small': 10,
  'small': 13,
  'medium': 16,
  'large': 18,
  'x-large': 24,
  'xx-large': 32,
  'xxx-large': 48,
};

// ---------------------------------------------------------------------------
// Shadows
// ---------------------------------------------------------------------------

class ShadowParseResult {
  ShadowParseResult(
    this.shadows, {
    this.hadInset = false,
    this.hadInvalid = false,
  });
  final List<UiShadow> shadows;
  final bool hadInset, hadInvalid;
}

ShadowParseResult parseBoxShadow(
  String input, {
  required double fontSize,
  required int currentColor,
}) {
  final out = <UiShadow>[];
  var inset = false, invalid = false;
  if (input.trim().toLowerCase() == 'none') return ShadowParseResult(out);
  for (final part in splitCommas(input)) {
    final nums = <double>[];
    int? color;
    var isInset = false;
    var bad = false;
    for (final t in splitTopLevel(part)) {
      if (t.toLowerCase() == 'inset') {
        isInset = true;
        continue;
      }
      final len = parseLen(t, fontSize: fontSize);
      if (len != null && len.isPx) {
        nums.add(len.value);
        continue;
      }
      final c = parseColor(t, currentColor: currentColor);
      if (c != null) {
        color = c;
        continue;
      }
      bad = true;
    }
    if (isInset) {
      inset = true;
      continue;
    }
    if (bad || nums.length < 2 || nums.length > 4) {
      invalid = true;
      continue;
    }
    out.add(
      UiShadow(
        dx: nums[0],
        dy: nums[1],
        blur: nums.length > 2 ? math.max(0, nums[2]) : 0,
        spread: nums.length > 3 ? nums[3] : 0,
        color: color ?? currentColor,
      ),
    );
  }
  return ShadowParseResult(out, hadInset: inset, hadInvalid: invalid);
}

// ---------------------------------------------------------------------------
// Gradients
// ---------------------------------------------------------------------------

/// Parses `linear-gradient(...)`. Returns null when the value is not a
/// supported linear gradient.
UiGradient? parseLinearGradient(
  String input, {
  required double fontSize,
  required int currentColor,
}) {
  final m = RegExp(
    r'^linear-gradient\((.*)\)$',
    dotAll: true,
  ).firstMatch(input.trim());
  if (m == null) return null;
  final args = splitCommas(m.group(1)!);
  if (args.length < 2) return null;

  var angle = 180.0;
  var stopArgs = args;
  final first = args.first.toLowerCase();
  if (first.startsWith('to ')) {
    final dir = first.substring(3).split(RegExp(r'\s+')).toSet();
    if (dir.containsAll({'top', 'right'})) {
      angle = 45;
    } else if (dir.containsAll({'bottom', 'right'})) {
      angle = 135;
    } else if (dir.containsAll({'bottom', 'left'})) {
      angle = 225;
    } else if (dir.containsAll({'top', 'left'})) {
      angle = 315;
    } else if (dir.contains('top')) {
      angle = 0;
    } else if (dir.contains('right')) {
      angle = 90;
    } else if (dir.contains('bottom')) {
      angle = 180;
    } else if (dir.contains('left')) {
      angle = 270;
    } else {
      return null;
    }
    stopArgs = args.sublist(1);
  } else {
    final am = RegExp(r'^([+-]?\d*\.?\d+)(deg|turn|rad|grad)$')
        .firstMatch(first);
    if (am != null) {
      final v = double.parse(am.group(1)!);
      switch (am.group(2)) {
        case 'deg':
          angle = v;
        case 'turn':
          angle = v * 360;
        case 'rad':
          angle = v * 180 / math.pi;
        case 'grad':
          angle = v * 0.9;
      }
      stopArgs = args.sublist(1);
    }
  }

  final colors = <int>[];
  final positions = <double?>[];
  for (final stop in stopArgs) {
    final tokens = splitTopLevel(stop);
    if (tokens.isEmpty) return null;
    double? pos;
    var colorTokens = tokens;
    if (tokens.length > 1 && tokens.last.endsWith('%')) {
      final v = double.tryParse(
        tokens.last.substring(0, tokens.last.length - 1),
      );
      if (v != null) {
        pos = v / 100;
        colorTokens = tokens.sublist(0, tokens.length - 1);
      }
    }
    final c = parseColor(colorTokens.join(' '), currentColor: currentColor);
    if (c == null) return null;
    colors.add(c);
    positions.add(pos);
  }
  if (colors.length < 2) return null;

  List<double>? stops;
  if (positions.any((p) => p != null)) {
    final filled = List<double?>.from(positions);
    filled[0] ??= 0;
    filled[filled.length - 1] ??= 1;
    var i = 0;
    while (i < filled.length) {
      if (filled[i] != null) {
        i++;
        continue;
      }
      final start = i - 1;
      var end = i;
      while (filled[end] == null) {
        end++;
      }
      for (var k = start + 1; k < end; k++) {
        filled[k] =
            filled[start]! +
            (filled[end]! - filled[start]!) * (k - start) / (end - start);
      }
      i = end;
    }
    var prev = 0.0;
    stops = [
      for (final p in filled) round3((prev = math.max(prev, p!.clamp(0, 1)))),
    ];
    // Evenly spaced stops are the default; no need to spell them out.
    var even = true;
    for (var i = 0; i < stops.length; i++) {
      if ((stops[i] - i / (stops.length - 1)).abs() > 0.001) even = false;
    }
    if (even) stops = null;
  }

  final rad = angle * math.pi / 180;
  var dx = math.sin(rad), dy = -math.cos(rad);
  final scale = 1 / math.max(dx.abs(), dy.abs());
  dx *= scale;
  dy *= scale;
  return UiGradient(
    colors: colors,
    stops: stops,
    beginX: round3(-dx),
    beginY: round3(-dy),
    endX: round3(dx),
    endY: round3(dy),
  );
}

// ---------------------------------------------------------------------------
// Named colors
// ---------------------------------------------------------------------------

const _namedColors = <String, int>{
  'aliceblue': 0xFFF0F8FF,
  'antiquewhite': 0xFFFAEBD7,
  'aqua': 0xFF00FFFF,
  'aquamarine': 0xFF7FFFD4,
  'azure': 0xFFF0FFFF,
  'beige': 0xFFF5F5DC,
  'bisque': 0xFFFFE4C4,
  'black': 0xFF000000,
  'blanchedalmond': 0xFFFFEBCD,
  'blue': 0xFF0000FF,
  'blueviolet': 0xFF8A2BE2,
  'brown': 0xFFA52A2A,
  'burlywood': 0xFFDEB887,
  'cadetblue': 0xFF5F9EA0,
  'chartreuse': 0xFF7FFF00,
  'chocolate': 0xFFD2691E,
  'coral': 0xFFFF7F50,
  'cornflowerblue': 0xFF6495ED,
  'cornsilk': 0xFFFFF8DC,
  'crimson': 0xFFDC143C,
  'cyan': 0xFF00FFFF,
  'darkblue': 0xFF00008B,
  'darkcyan': 0xFF008B8B,
  'darkgoldenrod': 0xFFB8860B,
  'darkgray': 0xFFA9A9A9,
  'darkgreen': 0xFF006400,
  'darkgrey': 0xFFA9A9A9,
  'darkkhaki': 0xFFBDB76B,
  'darkmagenta': 0xFF8B008B,
  'darkolivegreen': 0xFF556B2F,
  'darkorange': 0xFFFF8C00,
  'darkorchid': 0xFF9932CC,
  'darkred': 0xFF8B0000,
  'darksalmon': 0xFFE9967A,
  'darkseagreen': 0xFF8FBC8F,
  'darkslateblue': 0xFF483D8B,
  'darkslategray': 0xFF2F4F4F,
  'darkslategrey': 0xFF2F4F4F,
  'darkturquoise': 0xFF00CED1,
  'darkviolet': 0xFF9400D3,
  'deeppink': 0xFFFF1493,
  'deepskyblue': 0xFF00BFFF,
  'dimgray': 0xFF696969,
  'dimgrey': 0xFF696969,
  'dodgerblue': 0xFF1E90FF,
  'firebrick': 0xFFB22222,
  'floralwhite': 0xFFFFFAF0,
  'forestgreen': 0xFF228B22,
  'fuchsia': 0xFFFF00FF,
  'gainsboro': 0xFFDCDCDC,
  'ghostwhite': 0xFFF8F8FF,
  'gold': 0xFFFFD700,
  'goldenrod': 0xFFDAA520,
  'gray': 0xFF808080,
  'green': 0xFF008000,
  'greenyellow': 0xFFADFF2F,
  'grey': 0xFF808080,
  'honeydew': 0xFFF0FFF0,
  'hotpink': 0xFFFF69B4,
  'indianred': 0xFFCD5C5C,
  'indigo': 0xFF4B0082,
  'ivory': 0xFFFFFFF0,
  'khaki': 0xFFF0E68C,
  'lavender': 0xFFE6E6FA,
  'lavenderblush': 0xFFFFF0F5,
  'lawngreen': 0xFF7CFC00,
  'lemonchiffon': 0xFFFFFACD,
  'lightblue': 0xFFADD8E6,
  'lightcoral': 0xFFF08080,
  'lightcyan': 0xFFE0FFFF,
  'lightgoldenrodyellow': 0xFFFAFAD2,
  'lightgray': 0xFFD3D3D3,
  'lightgreen': 0xFF90EE90,
  'lightgrey': 0xFFD3D3D3,
  'lightpink': 0xFFFFB6C1,
  'lightsalmon': 0xFFFFA07A,
  'lightseagreen': 0xFF20B2AA,
  'lightskyblue': 0xFF87CEFA,
  'lightslategray': 0xFF778899,
  'lightslategrey': 0xFF778899,
  'lightsteelblue': 0xFFB0C4DE,
  'lightyellow': 0xFFFFFFE0,
  'lime': 0xFF00FF00,
  'limegreen': 0xFF32CD32,
  'linen': 0xFFFAF0E6,
  'magenta': 0xFFFF00FF,
  'maroon': 0xFF800000,
  'mediumaquamarine': 0xFF66CDAA,
  'mediumblue': 0xFF0000CD,
  'mediumorchid': 0xFFBA55D3,
  'mediumpurple': 0xFF9370DB,
  'mediumseagreen': 0xFF3CB371,
  'mediumslateblue': 0xFF7B68EE,
  'mediumspringgreen': 0xFF00FA9A,
  'mediumturquoise': 0xFF48D1CC,
  'mediumvioletred': 0xFFC71585,
  'midnightblue': 0xFF191970,
  'mintcream': 0xFFF5FFFA,
  'mistyrose': 0xFFFFE4E1,
  'moccasin': 0xFFFFE4B5,
  'navajowhite': 0xFFFFDEAD,
  'navy': 0xFF000080,
  'oldlace': 0xFFFDF5E6,
  'olive': 0xFF808000,
  'olivedrab': 0xFF6B8E23,
  'orange': 0xFFFFA500,
  'orangered': 0xFFFF4500,
  'orchid': 0xFFDA70D6,
  'palegoldenrod': 0xFFEEE8AA,
  'palegreen': 0xFF98FB98,
  'paleturquoise': 0xFFAFEEEE,
  'palevioletred': 0xFFDB7093,
  'papayawhip': 0xFFFFEFD5,
  'peachpuff': 0xFFFFDAB9,
  'peru': 0xFFCD853F,
  'pink': 0xFFFFC0CB,
  'plum': 0xFFDDA0DD,
  'powderblue': 0xFFB0E0E6,
  'purple': 0xFF800080,
  'rebeccapurple': 0xFF663399,
  'red': 0xFFFF0000,
  'rosybrown': 0xFFBC8F8F,
  'royalblue': 0xFF4169E1,
  'saddlebrown': 0xFF8B4513,
  'salmon': 0xFFFA8072,
  'sandybrown': 0xFFF4A460,
  'seagreen': 0xFF2E8B57,
  'seashell': 0xFFFFF5EE,
  'sienna': 0xFFA0522D,
  'silver': 0xFFC0C0C0,
  'skyblue': 0xFF87CEEB,
  'slateblue': 0xFF6A5ACD,
  'slategray': 0xFF708090,
  'slategrey': 0xFF708090,
  'snow': 0xFFFFFAFA,
  'springgreen': 0xFF00FF7F,
  'steelblue': 0xFF4682B4,
  'tan': 0xFFD2B48C,
  'teal': 0xFF008080,
  'thistle': 0xFFD8BFD8,
  'tomato': 0xFFFF6347,
  'turquoise': 0xFF40E0D0,
  'violet': 0xFFEE82EE,
  'wheat': 0xFFF5DEB3,
  'white': 0xFFFFFFFF,
  'whitesmoke': 0xFFF5F5F5,
  'yellow': 0xFFFFFF00,
  'yellowgreen': 0xFF9ACD32,
};
