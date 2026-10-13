// ignore_for_file: unused_element_parameter

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
                style: Theme.of(context).textTheme.headlineMedium,
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
            TextField(
              decoration: InputDecoration(border: OutlineInputBorder(), isDense: true, hintText: 'Jane Doe'),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 4),
              child: Text(
                'Email',
                style: TextStyle(fontSize: 13, fontFamily: 'Arial'),
              ),
            ),
            TextField(
              decoration: InputDecoration(border: OutlineInputBorder(), isDense: true, hintText: 'jane@example.com'),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 4),
              child: Text(
                'Password',
                style: TextStyle(fontSize: 13, fontFamily: 'Arial'),
              ),
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(border: OutlineInputBorder(), isDense: true, hintText: 'At least 8 characters'),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 4),
              child: Text(
                'Country',
                style: TextStyle(fontSize: 13, fontFamily: 'Arial'),
              ),
            ),
            DropdownMenu<String>(
              initialSelection: 'India',
              expandedInsets: EdgeInsets.zero,
              dropdownMenuEntries: [for (final o in ['India', 'Germany']) DropdownMenuEntry<String>(value: o, label: o)],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 14, fontFamily: 'Arial'),
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: MxSwitch(initial: true),
                    ),
                    const TextSpan(text: ' I agree to the terms'),
                  ],
                ),
              ),
            ),
            FilledButton(onPressed: () {}, child: Text('Create account')),
          ],
        ),
      ),
    );
  }
}

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
}
