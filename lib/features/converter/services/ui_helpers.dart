import '../models/ui_node.dart';
import '../models/ui_style.dart';

/// Decisions shared by the live preview renderer and the Dart code
/// generator, so both produce the same widget structure.

/// Fallback size of the placeholder shown for broken or missing images.
const placeholderWidth = 120.0;
const placeholderHeight = 90.0;

/// Primary accent used for form controls (browser-like blue).
const accentColor = 0xFF0075FF;

/// Differences between a text style and its base. Null fields are omitted.
class TextStyleDiff {
  TextStyleDiff({
    this.color,
    this.fontSize,
    this.weight,
    this.italic,
    this.underline,
    this.lineThrough,
    this.overline,
    this.fontFamily,
    this.height,
    this.letterSpacing,
  });

  final int? color;
  final double? fontSize;
  final int? weight;
  final bool? italic;

  /// Decoration flags are all non-null whenever any decoration differs.
  final bool? underline, lineThrough, overline;
  final String? fontFamily;
  final double? height;
  final double? letterSpacing;

  bool get hasDecoration => underline != null;

  bool get isEmpty =>
      color == null &&
      fontSize == null &&
      weight == null &&
      italic == null &&
      underline == null &&
      fontFamily == null &&
      height == null &&
      letterSpacing == null;
}

/// Computes what must be specified to turn [base] into [s]. With [full]
/// every property is emitted (used for Material controls, which bring their
/// own default text style).
TextStyleDiff diffTextStyle(
  UiTextStyle s,
  UiTextStyle base, {
  bool full = false,
}) {
  final decoChanged =
      s.underline != base.underline ||
      s.lineThrough != base.lineThrough ||
      s.overline != base.overline;
  final hasDeco = s.underline || s.lineThrough || s.overline;
  return TextStyleDiff(
    color: full || s.color != base.color ? s.color : null,
    fontSize: full || s.fontSize != base.fontSize ? s.fontSize : null,
    weight: full || s.weight != base.weight ? s.weight : null,
    italic: s.italic != base.italic || (full && s.italic) ? s.italic : null,
    underline: decoChanged || (full && hasDeco) ? s.underline : null,
    lineThrough: decoChanged || (full && hasDeco) ? s.lineThrough : null,
    overline: decoChanged || (full && hasDeco) ? s.overline : null,
    fontFamily: s.fontFamily != base.fontFamily ? s.fontFamily : null,
    height: s.height != base.height ? s.height : null,
    letterSpacing: s.letterSpacing != base.letterSpacing
        ? s.letterSpacing
        : null,
  );
}

/// Which wrappers a node's box needs.
class BoxPlan {
  BoxPlan({
    required this.padding,
    required this.margin,
    required this.size,
    required this.constraints,
    required this.decoration,
    required this.colorOnly,
    required this.clip,
  });

  final bool padding, margin, size, constraints, decoration;

  /// Only a flat background color: Container(color: ...) suffices.
  final bool colorOnly;

  /// Rounded corners clip the child.
  final bool clip;

  int get categories =>
      (padding ? 1 : 0) +
      (margin ? 1 : 0) +
      (size ? 1 : 0) +
      (constraints ? 1 : 0) +
      (decoration ? 1 : 0);
}

BoxPlan planBox(UiNode n) {
  final b = n.box;
  final sizeInside = n.kind == UiKind.image;
  final deco = b.hasDecoration;
  final onlyColor =
      deco &&
      b.background != null &&
      b.gradient == null &&
      !b.hasBorder &&
      (b.radius == null || b.radius!.isZero) &&
      b.shadows.isEmpty;
  return BoxPlan(
    padding: !b.padding.isZero,
    margin: !b.margin.isZero,
    size: !sizeInside && (b.width != null || b.height != null),
    constraints:
        b.minWidth != null ||
        b.maxWidth != null ||
        b.minHeight != null ||
        b.maxHeight != null,
    decoration: deco,
    colorOnly: onlyColor,
    clip: b.radius != null && !b.radius!.isZero,
  );
}

/// A block column with a single child and default alignment needs no Column.
bool collapsesToChild(UiNode n) =>
    n.kind == UiKind.column &&
    n.children.length == 1 &&
    n.mainAxis == UiMain.start &&
    n.crossAxis == UiCross.stretch &&
    n.gap == 0 &&
    n.alignX == null &&
    n.alignY == null &&
    n.widthFactor == null &&
    n.box.maxWidth == null &&
    n.box.minWidth == null &&
    !(n.flex != null && !n.flexTight);

/// Name of a standard `Alignment` constant, or null for custom values.
String? alignmentName(double x, double y) {
  return switch ((x, y)) {
    (-1.0, -1.0) => 'topLeft',
    (0.0, -1.0) => 'topCenter',
    (1.0, -1.0) => 'topRight',
    (-1.0, 0.0) => 'centerLeft',
    (0.0, 0.0) => 'center',
    (1.0, 0.0) => 'centerRight',
    (-1.0, 1.0) => 'bottomLeft',
    (0.0, 1.0) => 'bottomCenter',
    (1.0, 1.0) => 'bottomRight',
    _ => null,
  };
}

/// Whether the node builds as an empty box (no child content).
bool isEmptyBox(UiNode n) => n.kind == UiKind.column && n.children.isEmpty;

/// Alignment applied by [UiNode.alignX] / [UiNode.alignY], if any.
(double, double)? nodeAlignment(UiNode n) {
  if (n.alignX == null && n.alignY == null) return null;
  return (n.alignX ?? -1, n.alignY ?? -1);
}

/// Flutter `TextAlign` name for a [UiTextAlign].
String? textAlignName(UiTextAlign a) {
  switch (a) {
    case UiTextAlign.start:
      return null;
    case UiTextAlign.left:
      return 'left';
    case UiTextAlign.right:
      return 'right';
    case UiTextAlign.center:
      return 'center';
    case UiTextAlign.justify:
      return 'justify';
  }
}

String fitName(UiFit f) => f.name;
