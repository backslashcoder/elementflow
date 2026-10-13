/// Source of the small stateful widgets that make form controls interactive
/// in the generated Dart file. Each block is emitted only when used.
/// They mirror `widgets/interactive_controls.dart` used by the live preview.
const generatedCheckbox = '''
class _EfCheckbox extends StatefulWidget {
  const _EfCheckbox({required this.initial});

  final bool initial;

  @override
  State<_EfCheckbox> createState() => _EfCheckboxState();
}

class _EfCheckboxState extends State<_EfCheckbox> {
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
''';

const generatedRadio = '''
class _EfRadio extends StatefulWidget {
  const _EfRadio({
    required this.group,
    required this.id,
    required this.initial,
  });

  final String group;
  final int id;
  final bool initial;

  static final Map<String, ValueNotifier<int?>> _groups = {};

  @override
  State<_EfRadio> createState() => _EfRadioState();
}

class _EfRadioState extends State<_EfRadio> {
  late final ValueNotifier<int?> _selected;

  @override
  void initState() {
    super.initState();
    _selected = _EfRadio._groups.putIfAbsent(
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
              color: Color(on ? 0xFF0075FF : 0xFF767676),
            ),
          ),
        );
      },
    );
  }
}
''';

const generatedSlider = '''
class _EfSlider extends StatefulWidget {
  const _EfSlider({required this.initial});

  final double initial;

  @override
  State<_EfSlider> createState() => _EfSliderState();
}

class _EfSliderState extends State<_EfSlider> {
  late double _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _value,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}
''';

const generatedSelect = '''
class _EfSelect extends StatefulWidget {
  const _EfSelect({
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
  State<_EfSelect> createState() => _EfSelectState();
}

class _EfSelectState extends State<_EfSelect> {
  late int _index = widget.initial;

  @override
  Widget build(BuildContext context) {
    if (widget.options.isEmpty) {
      return InputDecorator(decoration: widget.decoration, child: const Text(''));
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
''';
