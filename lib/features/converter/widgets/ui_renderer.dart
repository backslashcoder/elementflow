import 'package:flutter/material.dart';

import '../models/conversion_result.dart';
import '../models/ui_node.dart';
import '../models/ui_style.dart';
import '../services/ui_helpers.dart';
import 'interactive_controls.dart';

/// Builds real Flutter widgets from the [UiNode] tree. It mirrors the
/// structure produced by `DartCodeGenerator`: both consume the same IR and
/// share the decisions in `ui_helpers.dart`.
class UiRenderer {
  const UiRenderer(this.context);

  final BuildContext context;

  static final _theme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(accentColor),
  );

  /// The full page: theme, scaffold, default text style and scroll view.
  static Widget page(BuildContext context, ConversionResult result) {
    return Theme(
      data: _theme,
      child: Scaffold(
        backgroundColor: Color(result.pageBackground ?? 0xFFFFFFFF),
        body: DefaultTextStyle(
          style: const TextStyle(
            color: Color(0xFF000000),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          child: SingleChildScrollView(
            child: UiRenderer(context).widget(result.root),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------- primitives

  static Color _c(int argb) => Color(argb);

  double _len(UiLen l, {required bool horizontal}) {
    switch (l.unit) {
      case UiUnit.px:
      case UiUnit.percent:
        return l.value;
      case UiUnit.vw:
        return MediaQuery.sizeOf(context).width * l.value / 100;
      case UiUnit.vh:
        return MediaQuery.sizeOf(context).height * l.value / 100;
    }
  }

  static EdgeInsets _insets(UiInsets i) =>
      EdgeInsets.fromLTRB(i.left, i.top, i.right, i.bottom);

  static Alignment _align(double x, double y) => Alignment(x, y);

  static BorderSide _side(UiBorderSide s) =>
      BorderSide(color: _c(s.color), width: s.width);

  static BorderRadius _radius(UiRadius r) => BorderRadius.only(
    topLeft: Radius.circular(r.topLeft),
    topRight: Radius.circular(r.topRight),
    bottomLeft: Radius.circular(r.bottomLeft),
    bottomRight: Radius.circular(r.bottomRight),
  );

  static BoxDecoration _decoration(UiBox b) {
    Border? border;
    if (b.hasBorder) {
      final bd = b.border!;
      border = bd.isUniform
          ? Border.all(color: _c(bd.top!.color), width: bd.top!.width)
          : Border(
              top: bd.top == null ? BorderSide.none : _side(bd.top!),
              right: bd.right == null ? BorderSide.none : _side(bd.right!),
              bottom: bd.bottom == null ? BorderSide.none : _side(bd.bottom!),
              left: bd.left == null ? BorderSide.none : _side(bd.left!),
            );
    }
    final g = b.gradient;
    return BoxDecoration(
      color: b.background == null ? null : _c(b.background!),
      gradient: g == null
          ? null
          : LinearGradient(
              begin: _align(g.beginX, g.beginY),
              end: _align(g.endX, g.endY),
              colors: [for (final c in g.colors) _c(c)],
              stops: g.stops,
            ),
      border: border,
      borderRadius: b.radius == null || b.radius!.isZero
          ? null
          : _radius(b.radius!),
      boxShadow: [
        for (final s in b.shadows)
          BoxShadow(
            color: _c(s.color),
            offset: Offset(s.dx, s.dy),
            blurRadius: s.blur,
            spreadRadius: s.spread,
          ),
      ],
    );
  }

  static TextStyle? _textStyle(
    UiTextStyle s,
    UiTextStyle base, {
    bool full = false,
  }) {
    final d = diffTextStyle(s, base, full: full);
    if (d.isEmpty) return null;
    TextDecoration? deco;
    if (d.hasDecoration) {
      final parts = [
        if (d.underline!) TextDecoration.underline,
        if (d.lineThrough!) TextDecoration.lineThrough,
        if (d.overline!) TextDecoration.overline,
      ];
      deco = parts.isEmpty
          ? TextDecoration.none
          : parts.length == 1
          ? parts.first
          : TextDecoration.combine(parts);
    }
    return TextStyle(
      color: d.color == null ? null : _c(d.color!),
      fontSize: d.fontSize,
      fontWeight: d.weight == null
          ? null
          : FontWeight.values[(d.weight! ~/ 100 - 1).clamp(0, 8)],
      fontStyle: d.italic == null
          ? null
          : (d.italic! ? FontStyle.italic : FontStyle.normal),
      decoration: deco,
      fontFamily: d.fontFamily,
      height: d.height,
      letterSpacing: d.letterSpacing,
    );
  }

  // --------------------------------------------------------------- nodes

  /// Widget for [n] including flex wrapper.
  Widget widget(UiNode n) {
    final w = _placed(n);
    if (n.flex == null) return w;
    return n.flexTight
        ? Expanded(flex: n.flex!, child: w)
        : Flexible(flex: n.flex!, child: w);
  }

  Widget _placed(UiNode n) {
    Widget w = _boxed(n);
    if (n.box.opacity < 1) w = Opacity(opacity: n.box.opacity, child: w);
    final al = nodeAlignment(n);
    if (n.widthFactor != null) {
      final a = al ?? (-1.0, -1.0);
      w = FractionallySizedBox(
        alignment: _align(a.$1, a.$2),
        widthFactor: n.widthFactor,
        child: w,
      );
    } else if (al != null) {
      w = Align(alignment: _align(al.$1, al.$2), child: w);
    }
    return w;
  }

  Widget _boxed(UiNode n) {
    final plan = planBox(n);
    final b = n.box;
    final content = _content(n);

    if (plan.categories == 0) return content ?? const SizedBox.shrink();

    if (plan.categories == 1) {
      if (plan.padding) {
        return Padding(padding: _insets(b.padding), child: content);
      }
      if (plan.margin) {
        return Padding(padding: _insets(b.margin), child: content);
      }
      if (plan.size) {
        return SizedBox(
          width: b.width == null ? null : _len(b.width!, horizontal: true),
          height: b.height == null ? null : _len(b.height!, horizontal: false),
          child: content,
        );
      }
    }

    final useColor = plan.decoration && plan.colorOnly && !plan.clip;
    return Container(
      width: plan.size && b.width != null
          ? _len(b.width!, horizontal: true)
          : null,
      height: plan.size && b.height != null
          ? _len(b.height!, horizontal: false)
          : null,
      constraints: plan.constraints
          ? BoxConstraints(
              minWidth: b.minWidth == null
                  ? 0
                  : _len(b.minWidth!, horizontal: true),
              maxWidth: b.maxWidth == null
                  ? double.infinity
                  : _len(b.maxWidth!, horizontal: true),
              minHeight: b.minHeight == null
                  ? 0
                  : _len(b.minHeight!, horizontal: false),
              maxHeight: b.maxHeight == null
                  ? double.infinity
                  : _len(b.maxHeight!, horizontal: false),
            )
          : null,
      padding: plan.padding ? _insets(b.padding) : null,
      margin: plan.margin ? _insets(b.margin) : null,
      color: useColor ? _c(b.background!) : null,
      decoration: plan.decoration && !useColor ? _decoration(b) : null,
      clipBehavior: plan.clip ? Clip.antiAlias : Clip.none,
      child: content,
    );
  }

  Widget? _content(UiNode n) {
    switch (n.kind) {
      case UiKind.column:
        if (n.children.isEmpty) return null;
        if (collapsesToChild(n)) return widget(n.children.first);
        return Column(
          mainAxisAlignment: _mainAlign(n.mainAxis),
          crossAxisAlignment: _crossAlign(n.crossAxis),
          spacing: n.gap,
          children: [for (final c in n.children) widget(c)],
        );
      case UiKind.row:
        if (n.children.isEmpty) return null;
        Widget row = Row(
          mainAxisAlignment: _mainAlign(n.mainAxis),
          crossAxisAlignment: _crossAlign(n.crossAxis),
          mainAxisSize: n.shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
          spacing: n.gap,
          children: [for (final c in n.children) widget(c)],
        );
        if (n.intrinsicHeight) row = IntrinsicHeight(child: row);
        return row;
      case UiKind.wrap:
        if (n.children.isEmpty) return null;
        return Wrap(
          spacing: n.gap,
          runSpacing: n.runGap,
          alignment: _wrapAlign(n.mainAxis),
          crossAxisAlignment: n.crossAxis == UiCross.end
              ? WrapCrossAlignment.end
              : n.crossAxis == UiCross.center
              ? WrapCrossAlignment.center
              : WrapCrossAlignment.start,
          children: [for (final c in n.children) widget(c)],
        );
      case UiKind.text:
        return _text(n);
      case UiKind.image:
        return _image(n);
      case UiKind.button:
        return _button(n);
      case UiKind.textField:
        return _textField(n);
      case UiKind.checkbox:
        return EfCheckbox(initial: n.checked);
      case UiKind.radio:
        return EfRadio(group: n.group, id: n.id, initial: n.checked);
      case UiKind.slider:
        return EfSlider(initial: double.tryParse(n.value ?? '') ?? 0.5);
      case UiKind.select:
        return EfSelect(
          options: n.options,
          initial: n.selectedIndex,
          style: _textStyle(n.textStyle, UiTextStyle.base, full: true)!,
          decoration: _inputDecoration(n),
        );
      case UiKind.divider:
        return Divider(
          height: n.dividerThickness,
          thickness: n.dividerThickness,
          color: _c(n.dividerColor),
        );
    }
  }

  static MainAxisAlignment _mainAlign(UiMain m) => switch (m) {
    UiMain.start => MainAxisAlignment.start,
    UiMain.end => MainAxisAlignment.end,
    UiMain.center => MainAxisAlignment.center,
    UiMain.spaceBetween => MainAxisAlignment.spaceBetween,
    UiMain.spaceAround => MainAxisAlignment.spaceAround,
    UiMain.spaceEvenly => MainAxisAlignment.spaceEvenly,
  };

  static WrapAlignment _wrapAlign(UiMain m) => switch (m) {
    UiMain.start => WrapAlignment.start,
    UiMain.end => WrapAlignment.end,
    UiMain.center => WrapAlignment.center,
    UiMain.spaceBetween => WrapAlignment.spaceBetween,
    UiMain.spaceAround => WrapAlignment.spaceAround,
    UiMain.spaceEvenly => WrapAlignment.spaceEvenly,
  };

  static CrossAxisAlignment _crossAlign(UiCross c) => switch (c) {
    UiCross.start => CrossAxisAlignment.start,
    UiCross.end => CrossAxisAlignment.end,
    UiCross.center => CrossAxisAlignment.center,
    UiCross.stretch => CrossAxisAlignment.stretch,
  };

  // ---------------------------------------------------------------- text

  Widget _text(UiNode n) {
    final align = switch (n.textAlign) {
      UiTextAlign.start => null,
      UiTextAlign.left => TextAlign.left,
      UiTextAlign.right => TextAlign.right,
      UiTextAlign.center => TextAlign.center,
      UiTextAlign.justify => TextAlign.justify,
    };
    final overflow = n.ellipsis ? TextOverflow.ellipsis : null;
    final spans = n.spans;
    if (spans.length == 1 && spans[0].widget == null) {
      return Text(
        spans[0].text!,
        style: _textStyle(spans[0].style, UiTextStyle.base),
        textAlign: align,
        softWrap: n.softWrap ? null : false,
        maxLines: n.maxLines,
        overflow: overflow,
      );
    }
    return Text.rich(
      TextSpan(
        style: _textStyle(n.textStyle, UiTextStyle.base),
        children: [
          for (final s in spans)
            if (s.widget != null)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: widget(s.widget!),
              )
            else
              TextSpan(text: s.text, style: _textStyle(s.style, n.textStyle)),
        ],
      ),
      textAlign: align,
      softWrap: n.softWrap ? null : false,
      maxLines: n.maxLines,
      overflow: overflow,
    );
  }

  // --------------------------------------------------------------- image

  Widget _image(UiNode n) {
    final w = n.box.width == null ? null : _len(n.box.width!, horizontal: true);
    final h = n.box.height == null
        ? null
        : _len(n.box.height!, horizontal: false);
    if (n.src == null || n.src!.isEmpty) {
      return _ImagePlaceholder(width: w, height: h);
    }
    return Image.network(
      n.src!,
      width: w,
      height: h,
      fit: BoxFit.values.byName(fitName(n.fit)),
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      errorBuilder: (context, error, stackTrace) =>
          _ImagePlaceholder(width: w, height: h),
    );
  }

  // ------------------------------------------------------------ controls

  Widget _button(UiNode n) {
    final c = n.control;
    final ts = n.textStyle;
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: _c(c.fill ?? 0x00000000),
        foregroundColor: _c(ts.color),
        elevation: c.hasShadow ? 2 : 0,
        padding: _insets(c.padding),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: c.radius > 0 || c.border != null
            ? RoundedRectangleBorder(
                borderRadius: c.radius > 0
                    ? BorderRadius.circular(c.radius)
                    : BorderRadius.zero,
                side: c.border == null ? BorderSide.none : _side(c.border!),
              )
            : null,
        textStyle: _textStyle(ts, UiTextStyle.base, full: true),
      ),
      child: Text(n.value ?? ''),
    );
  }

  InputDecoration _inputDecoration(UiNode n, {Widget? suffixIcon}) {
    final c = n.control;
    return InputDecoration(
      isDense: true,
      hintText: n.hint,
      filled: c.fill != null ? true : null,
      fillColor: c.fill == null ? null : _c(c.fill!),
      contentPadding: _insets(c.padding),
      suffixIcon: suffixIcon,
      border: c.border == null
          ? InputBorder.none
          : OutlineInputBorder(
              borderRadius: BorderRadius.circular(c.radius),
              borderSide: _side(c.border!),
            ),
    );
  }

  Widget _textField(UiNode n) {
    final style = _textStyle(n.textStyle, UiTextStyle.base, full: true);
    final expands = n.lines == 0;
    final multi = !expands && n.lines > 1;
    final hasValue = n.value != null && n.value!.isNotEmpty;
    final decoration = _inputDecoration(n);
    if (hasValue) {
      return TextFormField(
        initialValue: n.value,
        obscureText: n.obscure,
        style: style,
        minLines: multi ? n.lines : null,
        maxLines: expands ? null : (multi ? n.lines : 1),
        expands: expands,
        textAlignVertical: expands ? TextAlignVertical.top : null,
        decoration: decoration,
      );
    }
    return TextField(
      obscureText: n.obscure,
      style: style,
      minLines: multi ? n.lines : null,
      maxLines: expands ? null : (multi ? n.lines : 1),
      expands: expands,
      textAlignVertical: expands ? TextAlignVertical.top : null,
      decoration: decoration,
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? placeholderWidth,
      height: height ?? placeholderHeight,
      color: const Color(0xFFEEEEEE),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFF9E9E9E),
      ),
    );
  }
}
