import 'dart:convert';

import '../models/component_mapper.dart';

/// A ready-made component mapper offered in the "Mapper" menu.
class MapperSample {
  const MapperSample(this.name, this.description, this.json);
  final String name;
  final String description;
  final String json;

  ComponentMapper parse() => ComponentMapper.parse(json);
}

String _encode(Map<String, Object?> data) =>
    const JsonEncoder.withIndent('  ').convert(data);

/// Contents of the template downloaded from the mapper dialog.
final mapperTemplate = _encode({
  'name': 'My component library',
  'description': 'Maps HTML elements to my own widgets.',
  'imports': ['package:my_ui/my_ui.dart'],
  'components': [
    {
      'selector': 'button.primary',
      'widget': 'MyButton',
      'args': {'label': '{{text}}', 'onPressed': '() {}'},
    },
    {
      'selector': '.card',
      'widget': 'MyCard',
      'children': 'child',
      'args': {'child': '{{child}}'},
    },
  ],
});

final mapperSamples = <MapperSample>[
  MapperSample(
    'Material 3 widgets',
    'FilledButton, TextField, Card, DropdownMenu, Divider and text styles',
    _encode(_material),
  ),
  MapperSample(
    'Cupertino widgets',
    'iOS-style buttons, text fields, switch and headings from flutter/cupertino',
    _encode(_cupertino),
  ),
  MapperSample(
    'Acme UI (custom library)',
    'A self-contained design system: AcmeButton, AcmeField, AcmeCard and more',
    _encode(_acme),
  ),
];

// ---------------------------------------------------------------- Material 3

const _mxSwitch = '''
class MxSwitch extends StatefulWidget {
  const MxSwitch({super.key, required this.initial});

  final bool initial;

  @override
  State<MxSwitch> createState() => _MxSwitchState();
}

class _MxSwitchState extends State<MxSwitch> {
  late bool _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Switch(value: _value, onChanged: (v) => setState(() => _value = v));
  }
}''';

const _material = <String, Object?>{
  'name': 'Material 3 widgets',
  'description':
      'Maps common HTML elements to Flutter Material 3 components. '
      'Uses only the Flutter SDK, so the generated code runs as is.',
  'declarations': [_mxSwitch],
  'components': [
    {
      'selector': 'button',
      'widget': 'FilledButton',
      'args': {'onPressed': '() {}', 'child': 'Text({{text}})'},
    },
    {
      'selector': 'button.ghost, button.secondary',
      'widget': 'OutlinedButton',
      'args': {'onPressed': '() {}', 'child': 'Text({{text}})'},
    },
    {
      'selector': 'input[type=text], input[type=email]',
      'widget': 'TextField',
      'args': {
        'decoration': 'InputDecoration(border: OutlineInputBorder(), isDense: true, hintText: {{placeholder}})',
      },
    },
    {
      'selector': 'input[type=password]',
      'widget': 'TextField',
      'args': {
        'obscureText': 'true',
        'decoration': 'InputDecoration(border: OutlineInputBorder(), isDense: true, hintText: {{placeholder}})',
      },
    },
    {
      'selector': 'textarea',
      'widget': 'TextField',
      'args': {
        'minLines': '3',
        'maxLines': '3',
        'decoration': 'InputDecoration(border: OutlineInputBorder(), hintText: {{placeholder}})',
      },
    },
    {
      'selector': 'input[type=checkbox]',
      'widget': 'MxSwitch',
      'args': {'initial': '{{checked}}'},
    },
    {
      'selector': 'select',
      'widget': 'DropdownMenu<String>',
      'args': {
        'initialSelection': '{{selectedOption}}',
        'expandedInsets': 'EdgeInsets.zero',
        'dropdownMenuEntries': '[for (final o in {{options}}) DropdownMenuEntry<String>(value: o, label: o)]',
      },
    },
    {
      'selector': 'hr',
      'widget': 'Divider',
      'args': {'height': '24'},
    },
    {
      'selector': 'h1',
      'widget': 'Text',
      'positional': ['{{text}}'],
      'args': {'style': 'Theme.of(context).textTheme.headlineMedium'},
    },
    {
      'selector': 'h2',
      'widget': 'Text',
      'positional': ['{{text}}'],
      'args': {'style': 'Theme.of(context).textTheme.titleLarge'},
    },
    {
      'selector': 'h3',
      'widget': 'Text',
      'positional': ['{{text}}'],
      'args': {'style': 'Theme.of(context).textTheme.titleMedium'},
    },
    {
      'selector': '.card',
      'widget': 'Card',
      'children': 'child',
      'args': {
        'child': 'Padding(padding: const EdgeInsets.all(16), child: {{child}})',
      },
    },
    {
      'selector': '.tag, .badge',
      'widget': 'Chip',
      'args': {'label': 'Text({{text}})'},
    },
  ],
};

// ----------------------------------------------------------------- Cupertino

const _cupSwitch = '''
class CupSwitch extends StatefulWidget {
  const CupSwitch({super.key, required this.initial});

  final bool initial;

  @override
  State<CupSwitch> createState() => _CupSwitchState();
}

class _CupSwitchState extends State<CupSwitch> {
  late bool _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      value: _value,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}''';

const _cupertino = <String, Object?>{
  'name': 'Cupertino widgets',
  'description':
      'iOS-style components from package:flutter/cupertino.dart. '
      'Uses only the Flutter SDK.',
  'imports': ['package:flutter/cupertino.dart'],
  'declarations': [_cupSwitch],
  'components': [
    {
      'selector': 'button',
      'widget': 'CupertinoButton.filled',
      'args': {'onPressed': '() {}', 'child': 'Text({{text}})'},
    },
    {
      'selector': 'button.ghost, button.secondary',
      'widget': 'CupertinoButton',
      'args': {'onPressed': '() {}', 'child': 'Text({{text}})'},
    },
    {
      'selector': 'input[type=text], input[type=email]',
      'widget': 'CupertinoTextField',
      'args': {'placeholder': '{{placeholder}}'},
    },
    {
      'selector': 'input[type=password]',
      'widget': 'CupertinoTextField',
      'args': {'placeholder': '{{placeholder}}', 'obscureText': 'true'},
    },
    {
      'selector': 'textarea',
      'widget': 'CupertinoTextField',
      'args': {
        'placeholder': '{{placeholder}}',
        'minLines': '3',
        'maxLines': '3',
      },
    },
    {
      'selector': 'input[type=checkbox]',
      'widget': 'CupSwitch',
      'args': {'initial': '{{checked}}'},
    },
    {
      'selector': 'hr',
      'widget': 'Container',
      'args': {'height': '0.5', 'color': 'CupertinoColors.separator'},
    },
    {
      'selector': 'h1',
      'widget': 'Text',
      'positional': ['{{text}}'],
      'args': {
        'style': 'CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle',
      },
    },
    {
      'selector': 'h2, h3',
      'widget': 'Text',
      'positional': ['{{text}}'],
      'args': {
        'style': 'CupertinoTheme.of(context).textTheme.navTitleTextStyle',
      },
    },
    {
      'selector': '.card',
      'widget': 'Container',
      'children': 'child',
      'args': {
        'padding': 'const EdgeInsets.all(16)',
        'decoration': 'BoxDecoration(color: CupertinoColors.secondarySystemBackground, borderRadius: BorderRadius.circular(14))',
        'child': '{{child}}',
      },
    },
  ],
};

// ---------------------------------------------------------------------- Acme

const _acmeSource = '''
enum AcmeButtonKind { primary, ghost }

class AcmeButton extends StatelessWidget {
  const AcmeButton({
    super.key,
    required this.label,
    this.kind = AcmeButtonKind.primary,
    this.onPressed,
  });

  final String label;
  final AcmeButtonKind kind;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final primary = kind == AcmeButtonKind.primary;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: primary ? const Color(0xFF7C3AED) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF7C3AED), width: 1.5),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: primary ? Colors.white : const Color(0xFF7C3AED),
          ),
        ),
      ),
    );
  }
}

class AcmeField extends StatelessWidget {
  const AcmeField({super.key, this.hint, this.obscure = false, this.lines = 1});

  final String? hint;
  final bool obscure;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      minLines: lines,
      maxLines: lines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5F3FF),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class AcmeCard extends StatelessWidget {
  const AcmeCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x1F4C1D95), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}

class AcmeHeading extends StatelessWidget {
  const AcmeHeading(this.text, {super.key, this.level = 1});

  final String text;
  final int level;

  @override
  Widget build(BuildContext context) {
    final size = const [30.0, 24.0, 19.0][(level - 1).clamp(0, 2)];
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF2E1065),
      ),
    );
  }
}

class AcmeBadge extends StatelessWidget {
  const AcmeBadge({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF5B21B6)),
      ),
    );
  }
}

class AcmeCheck extends StatefulWidget {
  const AcmeCheck({super.key, required this.initial});

  final bool initial;

  @override
  State<AcmeCheck> createState() => _AcmeCheckState();
}

class _AcmeCheckState extends State<AcmeCheck> {
  late bool _on = widget.initial;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _on = !_on),
      child: Icon(
        _on ? Icons.check_circle : Icons.circle_outlined,
        color: const Color(0xFF7C3AED),
      ),
    );
  }
}''';

const _acme = <String, Object?>{
  'name': 'Acme UI (custom library)',
  'description':
      'Example of a team design system. The widgets are declared inside the '
      'mapper so the output is runnable; with a real library you would list '
      'its package under "imports" instead.',
  'theme':
      'ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF7C3AED))',
  'declarations': [_acmeSource],
  'components': [
    {
      'selector': 'button',
      'widget': 'AcmeButton',
      'args': {'label': '{{text}}', 'onPressed': '() {}'},
    },
    {
      'selector': 'button.ghost, button.secondary',
      'widget': 'AcmeButton',
      'args': {
        'label': '{{text}}',
        'kind': 'AcmeButtonKind.ghost',
        'onPressed': '() {}',
      },
    },
    {
      'selector': 'input[type=text], input[type=email]',
      'widget': 'AcmeField',
      'args': {'hint': '{{placeholder}}'},
    },
    {
      'selector': 'input[type=password]',
      'widget': 'AcmeField',
      'args': {'hint': '{{placeholder}}', 'obscure': 'true'},
    },
    {
      'selector': 'textarea',
      'widget': 'AcmeField',
      'args': {'hint': '{{placeholder}}', 'lines': '3'},
    },
    {
      'selector': 'input[type=checkbox]',
      'widget': 'AcmeCheck',
      'args': {'initial': '{{checked}}'},
    },
    {
      'selector': '.card',
      'widget': 'AcmeCard',
      'children': 'child',
      'args': {'child': '{{child}}'},
    },
    {
      'selector': 'h1',
      'widget': 'AcmeHeading',
      'positional': ['{{text}}'],
      'args': {'level': '1'},
    },
    {
      'selector': 'h2',
      'widget': 'AcmeHeading',
      'positional': ['{{text}}'],
      'args': {'level': '2'},
    },
    {
      'selector': 'h3',
      'widget': 'AcmeHeading',
      'positional': ['{{text}}'],
      'args': {'level': '3'},
    },
    {
      'selector': '.tag, .badge',
      'widget': 'AcmeBadge',
      'description':
          'Passes the CSS background color through as a style variable.',
      'args': {'label': '{{text}}', 'color': '{{style.backgroundColor}}'},
    },
  ],
};
