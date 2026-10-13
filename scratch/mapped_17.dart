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
            padding: const EdgeInsets.all(8),
            child: Container(
              constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height * 1),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.364, -1),
                  end: Alignment(0.364, 1),
                  colors: [Color(0xFF1A237E), Color(0xFF7B1FA2)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Welcome back',
                      style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
                    ),
                  ),
                  Container(
                    width: 368,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x59000000),
                          offset: Offset(0, 12),
                          blurRadius: 32,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text.rich(
                          TextSpan(
                            style: const TextStyle(fontFamily: 'Arial'),
                            children: [
                              const TextSpan(
                                text: 'Email',
                                style: TextStyle(
                                  color: Color(0xFF616161),
                                  fontSize: 13,
                                ),
                              ),
                              const TextSpan(text: ' '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                                  child: CupertinoTextField(
                                    placeholder: 'you@example.com',
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' '),
                              const TextSpan(
                                text: 'Password',
                                style: TextStyle(
                                  color: Color(0xFF616161),
                                  fontSize: 13,
                                ),
                              ),
                              const TextSpan(text: ' '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                                  child: CupertinoTextField(
                                    placeholder: 'Your password',
                                    obscureText: true,
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: CupertinoButton.filled(
                                  onPressed: () {},
                                  child: Text('Sign in'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'Forgot your password?',
                            style: TextStyle(
                              color: Color(0xFF757575),
                              fontSize: 13,
                              fontFamily: 'Arial',
                            ),
                            textAlign: TextAlign.center,
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
