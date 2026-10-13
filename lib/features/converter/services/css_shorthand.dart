import 'css_values.dart';

const _sides = ['top', 'right', 'bottom', 'left'];

const _borderStyles = {
  'none',
  'hidden',
  'solid',
  'dashed',
  'dotted',
  'double',
  'groove',
  'ridge',
  'inset',
  'outset',
};

const _fontWeightWords = {'normal', 'bold', 'bolder', 'lighter'};
const _fontStyleWords = {'italic', 'oblique'};

/// Expands CSS 1–4 value box syntax into top/right/bottom/left.
List<String>? _box(String value) {
  final t = splitTopLevel(value);
  switch (t.length) {
    case 1:
      return [t[0], t[0], t[0], t[0]];
    case 2:
      return [t[0], t[1], t[0], t[1]];
    case 3:
      return [t[0], t[1], t[2], t[1]];
    case 4:
      return t;
  }
  return null;
}

bool _isLengthLike(String t) =>
    RegExp(
      r'^[+-]?(\d+\.?\d*|\.\d+)[a-z%]*$',
      caseSensitive: false,
    ).hasMatch(t) ||
    t.startsWith('calc(') ||
    t.startsWith('var(') ||
    const {'thin', 'medium', 'thick'}.contains(t.toLowerCase());

/// Expands a shorthand declaration into longhands. Returns null when [prop]
/// is not a shorthand (or the value cannot be understood, in which case the
/// declaration is dropped by the caller as an unsupported value).
Map<String, String>? expandShorthand(String prop, String value) {
  switch (prop) {
    case 'margin':
    case 'padding':
      final b = _box(value);
      if (b == null) return {};
      return {for (var i = 0; i < 4; i++) '$prop-${_sides[i]}': b[i]};
    case 'margin-inline':
    case 'padding-inline':
    case 'margin-block':
    case 'padding-block':
      final base = prop.startsWith('margin') ? 'margin' : 'padding';
      final horizontal = prop.endsWith('inline');
      final t = splitTopLevel(value);
      if (t.isEmpty || t.length > 2) return {};
      final a = t[0], b = t.length > 1 ? t[1] : t[0];
      return horizontal
          ? {'$base-left': a, '$base-right': b}
          : {'$base-top': a, '$base-bottom': b};
    case 'border':
      return _borderSides(_sides, value);
    case 'border-top':
    case 'border-right':
    case 'border-bottom':
    case 'border-left':
      return _borderSides([prop.substring(7)], value);
    case 'border-width':
    case 'border-style':
    case 'border-color':
      final part = prop.substring(7);
      final b = _box(value);
      if (b == null) return {};
      return {for (var i = 0; i < 4; i++) 'border-${_sides[i]}-$part': b[i]};
    case 'border-radius':
      final first = value.split('/').first;
      final t = splitTopLevel(first);
      if (t.isEmpty || t.length > 4) return {};
      final tl = t[0];
      final tr = t.length >= 2 ? t[1] : t[0];
      final br = t.length >= 3 ? t[2] : tl;
      final bl = t.length == 4 ? t[3] : tr;
      return {
        'border-top-left-radius': tl,
        'border-top-right-radius': tr,
        'border-bottom-right-radius': br,
        'border-bottom-left-radius': bl,
      };
    case 'font':
      return _font(value);
    case 'background':
      return _background(value);
    case 'flex':
      return _flex(value);
    case 'flex-flow':
      final out = <String, String>{};
      for (final t in splitTopLevel(value)) {
        if (t.contains('wrap')) {
          out['flex-wrap'] = t;
        } else {
          out['flex-direction'] = t;
        }
      }
      return out;
    case 'gap':
    case 'grid-gap':
      final t = splitTopLevel(value);
      if (t.isEmpty || t.length > 2) return {};
      return {'row-gap': t[0], 'column-gap': t.length > 1 ? t[1] : t[0]};
    case 'overflow':
      final t = splitTopLevel(value);
      if (t.isEmpty || t.length > 2) return {};
      return {'overflow-x': t[0], 'overflow-y': t.length > 1 ? t[1] : t[0]};
    case 'text-decoration':
      final lines = splitTopLevel(value)
          .where(
            (t) => const {
              'underline',
              'overline',
              'line-through',
              'none',
            }.contains(t.toLowerCase()),
          )
          .toList();
      return {'text-decoration-line': lines.isEmpty ? 'none' : lines.join(' ')};
    case 'list-style':
      final type = splitTopLevel(
        value,
      ).where((t) => !t.startsWith('url(') && t != 'inside' && t != 'outside');
      return {'list-style-type': type.isEmpty ? 'disc' : type.first};
  }
  return null;
}

Map<String, String> _borderSides(List<String> sides, String value) {
  var width = 'medium', style = 'none';
  String? color;
  final tokens = splitTopLevel(value);
  if (tokens.isEmpty || tokens.length > 3) return {};
  for (final t in tokens) {
    if (_borderStyles.contains(t.toLowerCase())) {
      style = t.toLowerCase();
    } else if (_isLengthLike(t)) {
      width = t;
    } else {
      color = t;
    }
  }
  return {
    for (final s in sides) ...{
      'border-$s-width': width,
      'border-$s-style': style,
      'border-$s-color': color ?? 'currentcolor',
    },
  };
}

Map<String, String> _font(String value) {
  final tokens = splitTopLevel(value);
  final out = <String, String>{};
  var i = 0;
  for (; i < tokens.length; i++) {
    final t = tokens[i].toLowerCase();
    if (_fontStyleWords.contains(t)) {
      out['font-style'] = t == 'oblique' ? 'italic' : t;
    } else if (_fontWeightWords.contains(t) && t != 'normal') {
      out['font-weight'] = t;
    } else if (RegExp(r'^[1-9]00$').hasMatch(t)) {
      out['font-weight'] = t;
    } else if (t == 'normal' || t == 'small-caps') {
      continue;
    } else {
      break;
    }
  }
  if (i >= tokens.length) return {};
  final sizePart = tokens[i].split('/');
  out['font-size'] = sizePart[0];
  if (sizePart.length > 1 && sizePart[1].isNotEmpty) {
    out['line-height'] = sizePart[1];
  }
  i++;
  if (i < tokens.length) out['font-family'] = tokens.sublist(i).join(' ');
  return out;
}

Map<String, String> _background(String value) {
  final out = <String, String>{
    'background-color': 'transparent',
    'background-image': 'none',
  };
  for (final part in splitCommas(value).take(1)) {
    for (final t in splitTopLevel(part)) {
      final l = t.toLowerCase();
      if (l.contains('gradient(') || l.startsWith('url(')) {
        out['background-image'] = t;
      } else if (l == 'none') {
        continue;
      } else if (parseColor(t, currentColor: 0xFF000000) != null) {
        out['background-color'] = t;
      }
    }
  }
  return out;
}

Map<String, String> _flex(String value) {
  final v = value.trim().toLowerCase();
  if (v == 'none') {
    return {'flex-grow': '0', 'flex-shrink': '0', 'flex-basis': 'auto'};
  }
  if (v == 'auto') {
    return {'flex-grow': '1', 'flex-shrink': '1', 'flex-basis': 'auto'};
  }
  final t = splitTopLevel(v);
  final isNum = RegExp(r'^\d*\.?\d+$');
  if (t.length == 1) {
    if (isNum.hasMatch(t[0])) {
      return {'flex-grow': t[0], 'flex-shrink': '1', 'flex-basis': '0'};
    }
    return {'flex-grow': '1', 'flex-shrink': '1', 'flex-basis': t[0]};
  }
  if (t.length == 2) {
    return isNum.hasMatch(t[1])
        ? {'flex-grow': t[0], 'flex-shrink': t[1], 'flex-basis': '0'}
        : {'flex-grow': t[0], 'flex-shrink': '1', 'flex-basis': t[1]};
  }
  if (t.length == 3) {
    return {'flex-grow': t[0], 'flex-shrink': t[1], 'flex-basis': t[2]};
  }
  return {};
}
