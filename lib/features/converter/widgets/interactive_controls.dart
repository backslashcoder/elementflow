import 'package:flutter/material.dart';

import '../services/ui_helpers.dart';

/// Interactive form controls used by the live preview. The Dart generator
/// emits equivalent private widgets (`_EfCheckbox`, ...) into the generated
/// file (see `generated_helpers.dart`), so both behave the same.

class EfCheckbox extends StatefulWidget {
  const EfCheckbox({super.key, required this.initial});
  final bool initial;

  @override
  State<EfCheckbox> createState() => _EfCheckboxState();
}

class _EfCheckboxState extends State<EfCheckbox> {
  late bool _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: _value,
      onChanged: (v) => setState(() => _value = v ?? false),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class EfRadio extends StatefulWidget {
  const EfRadio({
    super.key,
    required this.group,
    required this.id,
    required this.initial,
  });
  final String group;
  final int id;
  final bool initial;

  static final Map<String, ValueNotifier<int?>> _groups = {};

  /// Forgets all radio selections (called when a new conversion renders).
  static void reset() => _groups.clear();

  @override
  State<EfRadio> createState() => _EfRadioState();
}

class _EfRadioState extends State<EfRadio> {
  late final ValueNotifier<int?> _selected;

  @override
  void initState() {
    super.initState();
    _selected = EfRadio._groups.putIfAbsent(
      widget.group,
      () => ValueNotifier<int?>(null),
    );
    if (widget.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _selected.value = widget.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: _selected,
      builder: (context, value, _) {
        final on = value == widget.id;
        return GestureDetector(
          onTap: () => _selected.value = widget.id,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Icon(
              on ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 20,
              color: Color(on ? accentColor : 0xFF767676),
            ),
          ),
        );
      },
    );
  }
}

class EfSlider extends StatefulWidget {
  const EfSlider({super.key, required this.initial});
  final double initial;

  @override
  State<EfSlider> createState() => _EfSliderState();
}

class _EfSliderState extends State<EfSlider> {
  late double _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Slider(value: _value, onChanged: (v) => setState(() => _value = v));
  }
}

class EfSelect extends StatefulWidget {
  const EfSelect({
    super.key,
    required this.options,
    required this.initial,
    required this.style,
    required this.decoration,
  });
  final List<String> options;
  final int initial;
  final TextStyle style;
  final InputDecoration decoration;

  @override
  State<EfSelect> createState() => _EfSelectState();
}

class _EfSelectState extends State<EfSelect> {
  late int _index = widget.initial;

  @override
  Widget build(BuildContext context) {
    if (widget.options.isEmpty) {
      return InputDecorator(
        decoration: widget.decoration,
        child: const Text(''),
      );
    }
    return InputDecorator(
      decoration: widget.decoration,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _index,
          isDense: true,
          isExpanded: true,
          style: widget.style,
          items: [
            for (var i = 0; i < widget.options.length; i++)
              DropdownMenuItem(value: i, child: Text(widget.options[i])),
          ],
          onChanged: (v) => setState(() => _index = v ?? _index),
        ),
      ),
    );
  }
}
