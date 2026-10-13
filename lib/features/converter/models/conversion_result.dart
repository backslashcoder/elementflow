import 'component_mapper.dart';
import 'ui_node.dart';

enum WarningLevel { info, warning }

class ConversionWarning {
  const ConversionWarning(
    this.message, {
    this.level = WarningLevel.warning,
    this.count = 1,
  });

  final String message;
  final WarningLevel level;

  /// How many times the issue occurred (identical warnings are merged).
  final int count;

  @override
  String toString() => message;
}

class ConversionResult {
  const ConversionResult({
    required this.root,
    required this.pageBackground,
    required this.title,
    required this.warnings,
    required this.elementsProcessed,
    required this.unsupportedFeatures,
    this.mapper,
    this.mappedWidgets = const {},
  });

  /// Root column representing `<body>`.
  final UiNode root;

  /// Page (canvas) background color, if the document sets one.
  final int? pageBackground;

  final String title;
  final List<ConversionWarning> warnings;
  final int elementsProcessed;

  /// Distinct feature names that could not be represented faithfully.
  final List<String> unsupportedFeatures;

  /// Component mapper used for this conversion, if any.
  final ComponentMapper? mapper;

  /// How many elements were mapped to each custom widget.
  final Map<String, int> mappedWidgets;

  int get mappedCount => mappedWidgets.values.fold(0, (a, b) => a + b);

  int get warningCount =>
      warnings.where((w) => w.level == WarningLevel.warning).length;
  int get infoCount =>
      warnings.where((w) => w.level == WarningLevel.info).length;
}

/// Thrown for input that cannot be converted at all.
class ConversionException implements Exception {
  const ConversionException(this.message);
  final String message;

  @override
  String toString() => message;
}
