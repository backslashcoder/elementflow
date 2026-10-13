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
    return const Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: DefaultTextStyle(
        style: TextStyle(
          color: Color(0xFF000000),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        child: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.all(8), child: _FormSection()),
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 468),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 17.42, bottom: 4),
              child: Text(
                'Create your account',
                style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'It only takes a minute.',
                style: TextStyle(color: Color(0xFF757575), fontFamily: 'Arial'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'Full name',
                style: TextStyle(fontSize: 13, fontFamily: 'Arial'),
              ),
            ),
            CupertinoTextField(placeholder: 'Jane Doe'),
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 4),
              child: Text(
                'Email',
                style: TextStyle(fontSize: 13, fontFamily: 'Arial'),
              ),
            ),
            CupertinoTextField(placeholder: 'jane@example.com'),
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 4),
              child: Text(
                'Password',
                style: TextStyle(fontSize: 13, fontFamily: 'Arial'),
              ),
            ),
            CupertinoTextField(
              placeholder: 'At least 8 characters',
              obscureText: true,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 4),
              child: Text(
                'Country',
                style: TextStyle(fontSize: 13, fontFamily: 'Arial'),
              ),
            ),
            _EfSelect(
              options: const ['India', 'Germany'],
              initial: 0,
              style: const TextStyle(
                color: Color(0xFF000000),
                fontSize: 13.333,
                fontWeight: FontWeight.w400,
                fontFamily: 'Arial',
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFFFFFFF),
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 14, fontFamily: 'Arial'),
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: CupSwitch(initial: true),
                    ),
                    const TextSpan(text: ' I agree to the terms'),
                  ],
                ),
              ),
            ),
            CupertinoButton.filled(
              onPressed: () {},
              child: Text('Create account'),
            ),
          ],
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
