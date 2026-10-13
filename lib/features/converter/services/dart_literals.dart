import '../models/ui_style.dart';

/// Formatting of Dart source literals, shared by the code generator and the
/// converter (which pre-computes values for component mappers).

String dartNum(num v) {
  if (v == double.infinity) return 'double.infinity';
  final d = v.toDouble();
  if (d == d.roundToDouble()) return d.toInt().toString();
  var s = d.toStringAsFixed(3);
  s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  return s;
}

/// A single-quoted, fully escaped Dart string literal.
String dartString(String s) {
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

String dartColor(int argb) =>
    'Color(0x${argb.toRadixString(16).toUpperCase().padLeft(8, '0')})';

String dartInsets(UiInsets i) {
  if (i.isZero) return 'EdgeInsets.zero';
  if (i.isUniform) return 'EdgeInsets.all(${dartNum(i.top)})';
  if (i.top == i.bottom && i.left == i.right) {
    return 'EdgeInsets.symmetric(vertical: ${dartNum(i.top)}, '
        'horizontal: ${dartNum(i.left)})';
  }
  return 'EdgeInsets.fromLTRB(${dartNum(i.left)}, ${dartNum(i.top)}, '
      '${dartNum(i.right)}, ${dartNum(i.bottom)})';
}
