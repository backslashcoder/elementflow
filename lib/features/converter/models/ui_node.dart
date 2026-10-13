import 'ui_style.dart';

enum UiKind {
  column,
  row,
  wrap,
  text,
  image,
  button,
  textField,
  checkbox,
  radio,
  slider,
  select,
  divider,
}

enum UiMain { start, end, center, spaceBetween, spaceAround, spaceEvenly }

enum UiCross { start, end, center, stretch }

enum UiFit { fill, contain, cover, fitWidth, fitHeight, none, scaleDown }

/// A run of inline content: either styled text or an embedded node.
class UiSpan {
  const UiSpan.text(String this.text, this.style) : widget = null;
  const UiSpan.widget(UiNode this.widget)
    : text = null,
      style = UiTextStyle.base;

  final String? text;
  final UiTextStyle style;
  final UiNode? widget;
}

/// One node of the normalized UI tree. Both the live Flutter preview and the
/// Dart code generator render this same structure; every layout decision
/// (flex wrappers, alignment, shrink-wrapping...) is already resolved here.
class UiNode {
  UiNode(
    this.kind, {
    this.tag = 'div',
    this.label,
    this.box = UiBox.empty,
    List<UiNode>? children,
  }) : children = children ?? [];

  final UiKind kind;

  /// Source tag name, used for naming extracted widgets.
  final String tag;

  /// Source id or first class, used for naming extracted widgets.
  final String? label;

  UiBox box;
  List<UiNode> children;

  // ---- Flex / column / row / wrap container behaviour -------------------
  UiMain mainAxis = UiMain.start;
  UiCross crossAxis = UiCross.stretch;
  double gap = 0;
  double runGap = 0;

  /// Wrap the row in an IntrinsicHeight so stretched children share a height.
  bool intrinsicHeight = false;

  /// Row sized to its content instead of the full available width.
  bool shrinkWrap = false;

  // ---- Placement inside the parent (set while the parent is converted) --
  int? flex;
  bool flexTight = false;

  /// Alignment (-1..1) used to position a width-constrained child.
  double? alignX, alignY;

  /// Fraction of the parent's width (percentage widths).
  double? widthFactor;

  // ---- Text -------------------------------------------------------------
  List<UiSpan> spans = [];
  UiTextStyle textStyle = UiTextStyle.base;
  UiTextAlign textAlign = UiTextAlign.start;
  bool softWrap = true;
  bool ellipsis = false;
  int? maxLines;

  // ---- Image ------------------------------------------------------------
  String? src;
  String? alt;
  UiFit fit = UiFit.fill;

  // ---- Controls ---------------------------------------------------------
  String? value;
  String? hint;
  bool obscure = false;
  bool checked = false;

  /// Radio group name and a per-conversion unique id for checkbox/radio.
  String group = '';
  int id = 0;

  /// Initially selected option of a select.
  int selectedIndex = 0;
  int lines = 1;
  List<String> options = const [];
  UiControlStyle control = const UiControlStyle();

  // ---- Divider ----------------------------------------------------------
  int dividerColor = 0xFFBDBDBD;
  double dividerThickness = 1;

  bool get isInline => kind == UiKind.text;

  /// Number of nodes in this subtree (including WidgetSpan content).
  int get size {
    var n = 1;
    for (final c in children) {
      n += c.size;
    }
    for (final s in spans) {
      if (s.widget != null) n += s.widget!.size;
    }
    return n;
  }
}
