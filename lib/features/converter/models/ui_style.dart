/// Style value objects used by the intermediate representation.
/// Colors are stored as ARGB ints (0xAARRGGBB).
library;

class UiInsets {
  const UiInsets(this.top, this.right, this.bottom, this.left);
  const UiInsets.all(double v) : this(v, v, v, v);

  static const zero = UiInsets(0, 0, 0, 0);

  final double top, right, bottom, left;

  bool get isZero => top == 0 && right == 0 && bottom == 0 && left == 0;
  bool get isUniform => top == right && right == bottom && bottom == left;
  double get horizontal => left + right;
  double get vertical => top + bottom;

  UiInsets copyWith({
    double? top,
    double? right,
    double? bottom,
    double? left,
  }) => UiInsets(
    top ?? this.top,
    right ?? this.right,
    bottom ?? this.bottom,
    left ?? this.left,
  );

  @override
  bool operator ==(Object other) =>
      other is UiInsets &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom &&
      other.left == left;

  @override
  int get hashCode => Object.hash(top, right, bottom, left);

  @override
  String toString() => 'UiInsets($top, $right, $bottom, $left)';
}

enum UiUnit { px, percent, vw, vh }

/// A length that is either absolute or relative to parent / viewport.
class UiLen {
  const UiLen(this.value, [this.unit = UiUnit.px]);
  final double value;
  final UiUnit unit;

  bool get isPx => unit == UiUnit.px;
  bool get isPercent => unit == UiUnit.percent;

  UiLen plus(double px) => isPx ? UiLen(value + px) : this;

  @override
  bool operator ==(Object other) =>
      other is UiLen && other.value == value && other.unit == unit;

  @override
  int get hashCode => Object.hash(value, unit);

  @override
  String toString() => '$value${unit.name}';
}

class UiBorderSide {
  const UiBorderSide(this.width, this.color);
  final double width;
  final int color;

  @override
  bool operator ==(Object other) =>
      other is UiBorderSide && other.width == width && other.color == color;

  @override
  int get hashCode => Object.hash(width, color);
}

class UiBorder {
  const UiBorder({this.top, this.right, this.bottom, this.left});
  final UiBorderSide? top, right, bottom, left;

  bool get isEmpty =>
      top == null && right == null && bottom == null && left == null;

  bool get isUniform =>
      top != null && top == right && right == bottom && bottom == left;

  UiBorder without({bool top = false, bool left = false}) => UiBorder(
    top: top ? null : this.top,
    right: right,
    bottom: bottom,
    left: left ? null : this.left,
  );

  double get horizontalWidth => (left?.width ?? 0) + (right?.width ?? 0);
  double get verticalWidth => (top?.width ?? 0) + (bottom?.width ?? 0);
}

class UiRadius {
  const UiRadius(
    this.topLeft,
    this.topRight,
    this.bottomRight,
    this.bottomLeft,
  );
  const UiRadius.all(double v) : this(v, v, v, v);

  final double topLeft, topRight, bottomRight, bottomLeft;

  bool get isZero =>
      topLeft == 0 && topRight == 0 && bottomRight == 0 && bottomLeft == 0;
  bool get isUniform =>
      topLeft == topRight &&
      topRight == bottomRight &&
      bottomRight == bottomLeft;
}

class UiShadow {
  const UiShadow({
    required this.dx,
    required this.dy,
    required this.blur,
    required this.spread,
    required this.color,
  });
  final double dx, dy, blur, spread;
  final int color;
}

class UiGradient {
  const UiGradient({
    required this.colors,
    this.stops,
    required this.beginX,
    required this.beginY,
    required this.endX,
    required this.endY,
  });
  final List<int> colors;
  final List<double>? stops;

  /// Alignment coordinates in the -1..1 range.
  final double beginX, beginY, endX, endY;
}

enum UiTextAlign { start, left, right, center, justify }

class UiTextStyle {
  const UiTextStyle({
    this.color = 0xFF000000,
    this.fontSize = 16,
    this.weight = 400,
    this.italic = false,
    this.underline = false,
    this.lineThrough = false,
    this.overline = false,
    this.fontFamily,
    this.height,
    this.letterSpacing,
  });

  static const base = UiTextStyle();

  final int color;
  final double fontSize;

  /// 100..900
  final int weight;
  final bool italic, underline, lineThrough, overline;
  final String? fontFamily;

  /// Line height as a multiple of the font size.
  final double? height;
  final double? letterSpacing;

  @override
  bool operator ==(Object other) =>
      other is UiTextStyle &&
      other.color == color &&
      other.fontSize == fontSize &&
      other.weight == weight &&
      other.italic == italic &&
      other.underline == underline &&
      other.lineThrough == lineThrough &&
      other.overline == overline &&
      other.fontFamily == fontFamily &&
      other.height == height &&
      other.letterSpacing == letterSpacing;

  @override
  int get hashCode => Object.hash(
    color,
    fontSize,
    weight,
    italic,
    underline,
    lineThrough,
    overline,
    fontFamily,
    height,
    letterSpacing,
  );
}

/// Box-model properties common to every node.
class UiBox {
  const UiBox({
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.padding = UiInsets.zero,
    this.margin = UiInsets.zero,
    this.background,
    this.gradient,
    this.border,
    this.radius,
    this.shadows = const [],
    this.opacity = 1,
    this.clip = false,
    this.marginLeftAuto = false,
    this.marginRightAuto = false,
  });

  static const empty = UiBox();

  final UiLen? width, height, minWidth, maxWidth, minHeight, maxHeight;
  final UiInsets padding, margin;
  final int? background;
  final UiGradient? gradient;
  final UiBorder? border;
  final UiRadius? radius;
  final List<UiShadow> shadows;
  final double opacity;
  final bool clip;
  final bool marginLeftAuto, marginRightAuto;

  bool get hasBorder => border != null && !border!.isEmpty;

  bool get hasDecoration =>
      background != null ||
      gradient != null ||
      hasBorder ||
      (radius != null && !radius!.isZero) ||
      shadows.isNotEmpty;

  /// Whether the box paints anything visible (used for stretch decisions).
  bool get isVisual =>
      background != null || gradient != null || hasBorder || shadows.isNotEmpty;

  bool get hasHorizontalSizing =>
      width != null || maxWidth != null || minWidth != null;

  UiBox copyWith({
    UiLen? width,
    UiLen? height,
    UiLen? minWidth,
    UiLen? maxWidth,
    UiLen? minHeight,
    UiInsets? padding,
    UiInsets? margin,
    UiBorder? border,
    bool clearWidth = false,
    bool clearHeight = false,
    bool clearBackground = false,
    bool clearBorder = false,
    bool clearShadows = false,
    bool clearRadius = false,
  }) => UiBox(
    width: clearWidth ? null : (width ?? this.width),
    height: clearHeight ? null : (height ?? this.height),
    minWidth: minWidth ?? this.minWidth,
    maxWidth: maxWidth ?? this.maxWidth,
    minHeight: minHeight ?? this.minHeight,
    maxHeight: maxHeight,
    padding: padding ?? this.padding,
    margin: margin ?? this.margin,
    background: clearBackground ? null : background,
    gradient: clearBackground ? null : gradient,
    border: clearBorder ? null : (border ?? this.border),
    radius: clearRadius ? null : radius,
    shadows: clearShadows ? const [] : shadows,
    opacity: opacity,
    clip: clip,
    marginLeftAuto: marginLeftAuto,
    marginRightAuto: marginRightAuto,
  );
}

/// Visual style of form controls and buttons, which Flutter configures
/// through the control itself rather than a surrounding container.
class UiControlStyle {
  const UiControlStyle({
    this.fill,
    this.border,
    this.radius = 0,
    this.padding = UiInsets.zero,
    this.hasShadow = false,
  });
  final int? fill;
  final UiBorderSide? border;
  final double radius;
  final UiInsets padding;
  final bool hasShadow;
}
