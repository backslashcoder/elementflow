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
              padding: const EdgeInsets.all(24),
              color: const Color(0xFFF5F5F5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Simple pricing',
                      style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Text(
                      'Pick a plan that grows with you.',
                      style: TextStyle(color: Color(0xFF616161), fontFamily: 'Arial'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 16,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Free',
                                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    '\$0',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 24,
                                            padding: const EdgeInsets.only(right: 8),
                                            child: const Text(
                                              '•',
                                              style: TextStyle(
                                                color: Color(0xFF616161),
                                                fontFamily: 'Arial',
                                                height: 1.8,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          const Expanded(
                                            child: Text(
                                              '1 project',
                                              style: TextStyle(
                                                color: Color(0xFF616161),
                                                fontFamily: 'Arial',
                                                height: 1.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 24,
                                            padding: const EdgeInsets.only(right: 8),
                                            child: const Text(
                                              '•',
                                              style: TextStyle(
                                                color: Color(0xFF616161),
                                                fontFamily: 'Arial',
                                                height: 1.8,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          const Expanded(
                                            child: Text(
                                              'Community support',
                                              style: TextStyle(
                                                color: Color(0xFF616161),
                                                fontFamily: 'Arial',
                                                height: 1.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3F51B5),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x663F51B5),
                                  offset: Offset(0, 8),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Pro',
                                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    '\$12',
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 24,
                                            padding: const EdgeInsets.only(right: 8),
                                            child: const Text(
                                              '•',
                                              style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontFamily: 'Arial',
                                                height: 1.8,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          const Expanded(
                                            child: Text(
                                              'Unlimited projects',
                                              style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontFamily: 'Arial',
                                                height: 1.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 24,
                                            padding: const EdgeInsets.only(right: 8),
                                            child: const Text(
                                              '•',
                                              style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontFamily: 'Arial',
                                                height: 1.8,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          const Expanded(
                                            child: Text(
                                              'Priority support',
                                              style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontFamily: 'Arial',
                                                height: 1.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                CupertinoButton.filled(
                                  onPressed: () {},
                                  child: Text('Get Pro'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Team',
                                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    '\$49',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 24,
                                            padding: const EdgeInsets.only(right: 8),
                                            child: const Text(
                                              '•',
                                              style: TextStyle(
                                                color: Color(0xFF616161),
                                                fontFamily: 'Arial',
                                                height: 1.8,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          const Expanded(
                                            child: Text(
                                              '10 seats',
                                              style: TextStyle(
                                                color: Color(0xFF616161),
                                                fontFamily: 'Arial',
                                                height: 1.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 24,
                                            padding: const EdgeInsets.only(right: 8),
                                            child: const Text(
                                              '•',
                                              style: TextStyle(
                                                color: Color(0xFF616161),
                                                fontFamily: 'Arial',
                                                height: 1.8,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          const Expanded(
                                            child: Text(
                                              'SSO & audit log',
                                              style: TextStyle(
                                                color: Color(0xFF616161),
                                                fontFamily: 'Arial',
                                                height: 1.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
