import '../models/conversion_result.dart';

/// Collects conversion warnings, merging repeated occurrences of the same
/// issue into a single entry with a count.
class WarningCollector {
  final _entries = <String, _Entry>{};
  final unsupportedFeatures = <String>{};

  /// Records a warning. Warnings sharing [key] are merged; the first message
  /// wins. [feature] additionally lists the item in the unsupported summary.
  void add(
    String key,
    String message, {
    WarningLevel level = WarningLevel.warning,
    String? feature,
  }) {
    final e = _entries[key];
    if (e == null) {
      _entries[key] = _Entry(message, level);
    } else {
      e.count++;
    }
    if (feature != null && level == WarningLevel.warning) {
      unsupportedFeatures.add(feature);
    }
  }

  List<ConversionWarning> get warnings =>
      [
        for (final e in _entries.values)
          ConversionWarning(e.message, level: e.level, count: e.count),
      ]..sort(
        (a, b) => a.level.index == b.level.index
            ? 0
            : (a.level == WarningLevel.warning ? -1 : 1),
      );
}

class _Entry {
  _Entry(this.message, this.level);
  final String message;
  final WarningLevel level;
  int count = 1;
}
