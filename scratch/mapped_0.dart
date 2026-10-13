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
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    child: Padding(padding: const EdgeInsets.all(16), child: const Text('inside card')),
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: TextField(
                          decoration: InputDecoration(border: OutlineInputBorder(), isDense: true, hintText: 'Name'),
                        ),
                      ),
                      const TextSpan(text: ' '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: TextField(
                          obscureText: true,
                          decoration: InputDecoration(border: OutlineInputBorder(), isDense: true, hintText: 'Secret'),
                        ),
                      ),
                      const TextSpan(text: ' '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: MxSwitch(initial: true),
                      ),
                      const TextSpan(text: ' '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: DropdownMenu<String>(
                          initialSelection: 'Two',
                          expandedInsets: EdgeInsets.zero,
                          dropdownMenuEntries: [for (final o in ['One', 'Two']) DropdownMenuEntry<String>(value: o, label: o)],
                        ),
                      ),
                      const TextSpan(text: ' '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: FilledButton(onPressed: () {}, child: Text('Save')),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: OutlinedButton(
                          onPressed: () {},
                          child: Text('Cancel'),
                        ),
                      ),
                      const TextSpan(text: ' '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Chip(label: Text('new')),
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
