// ignore_for_file: unused_element_parameter

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const GeneratedApp());
}

class GeneratedApp extends StatelessWidget {
  const GeneratedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ElementFlow Page',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0075FF),
      ),
      home: const GeneratedPage(),
    );
  }
}

class GeneratedPage extends StatelessWidget {
  const GeneratedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: DefaultTextStyle(
        style: const TextStyle(
          color: Color(0xFF000000),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 21.44, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 21.44),
                  child: Text(
                    'Welcome',
                    style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: CupertinoColors.secondarySystemBackground, borderRadius: BorderRadius.circular(14)),
                    child: const Text('inside card'),
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: CupertinoTextField(placeholder: 'Name'),
                      ),
                      const TextSpan(text: ' '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: CupertinoTextField(
                          placeholder: 'Secret',
                          obscureText: true,
                        ),
                      ),
                      const TextSpan(text: ' '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: CupSwitch(initial: true),
                      ),
                      const TextSpan(text: ' '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: SizedBox(
                          width: 152,
                          child: _EfSelect(
                            options: const ['One', 'Two'],
                            initial: 1,
                            style: const TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 13.333,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: const Color(0xFFFFFFFF),
                              contentPadding: const EdgeInsets.all(0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                                borderSide: const BorderSide(color: Color(0xFF767676)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: ' '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: CupertinoButton.filled(
                          onPressed: () {},
                          child: Text('Save'),
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: CupertinoButton(
                          onPressed: () {},
                          child: Text('Cancel'),
                        ),
                      ),
                      const TextSpan(text: ' '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 8,
                          ),
                          color: const Color(0xFFFF0000),
                          child: const Text('new'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
}
