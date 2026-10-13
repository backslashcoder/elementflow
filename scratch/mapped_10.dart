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
      title: 'Aurora Coffee',
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
      backgroundColor: const Color(0xFFFFFAF3),
      body: DefaultTextStyle(
        style: const TextStyle(
          color: Color(0xFF000000),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                color: const Color(0xFF6D4C41),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'AURORA COFFEE',
                        style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
                      ),
                    ),
                    const Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 20,
                        children: [
                          Flexible(
                            child: Text(
                              'Menu',
                              style: TextStyle(
                                color: Color(0xFFFFE0B2),
                                fontSize: 15,
                                fontFamily: 'Georgia',
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              'About',
                              style: TextStyle(
                                color: Color(0xFFFFE0B2),
                                fontSize: 15,
                                fontFamily: 'Georgia',
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              'Contact',
                              style: TextStyle(
                                color: Color(0xFFFFE0B2),
                                fontSize: 15,
                                fontFamily: 'Georgia',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6D4C41), Color(0xFFFF8F00)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Freshly roasted, every morning',
                        style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 520),
                        margin: const EdgeInsets.only(bottom: 24),
                        child: const Text(
                          'Small-batch beans from family farms, roasted in-house and delivered to your door.',
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 18,
                            fontFamily: 'Georgia',
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: CupertinoButton.filled(
                        onPressed: () {},
                        child: Text('Order now'),
                      ),
                    ),
                  ],
                ),
              ),
              const _FeaturesSection(),
              const _MenuSection(),
              const _ContactSection(),
              Container(
                padding: const EdgeInsets.all(20),
                color: const Color(0xFF3E2723),
                child: const Text.rich(
                  TextSpan(
                    style: TextStyle(
                      color: Color(0xFFD7CCC8),
                      fontSize: 14,
                      fontFamily: 'Georgia',
                    ),
                    children: [
                      TextSpan(text: '© 2026 Aurora Coffee · '),
                      TextSpan(
                        text: 'Back to top',
                        style: TextStyle(
                          color: Color(0xFFFFCC80),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 20,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: CupertinoColors.secondarySystemBackground, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Single origin',
                        style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                      ),
                    ),
                    const Text.rich(
                      TextSpan(
                        style: TextStyle(
                          color: Color(0xFF3E2723),
                          fontSize: 15,
                          fontFamily: 'Georgia',
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(text: 'Traceable beans with '),
                          TextSpan(
                            text: 'bright, fruity',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: ' notes.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: CupertinoColors.secondarySystemBackground, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Slow roasted',
                        style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                      ),
                    ),
                    const Text.rich(
                      TextSpan(
                        style: TextStyle(
                          color: Color(0xFF3E2723),
                          fontSize: 15,
                          fontFamily: 'Georgia',
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(text: 'Balanced and '),
                          TextSpan(
                            text: 'smooth',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          TextSpan(text: ', never bitter.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: CupertinoColors.secondarySystemBackground, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Fair trade',
                        style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                      ),
                    ),
                    const Text(
                      'We pay farmers well — and it shows in the cup.',
                      style: TextStyle(
                        color: Color(0xFF3E2723),
                        fontSize: 15,
                        fontFamily: 'Georgia',
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
      margin: const EdgeInsets.only(top: 19.92),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 19.92),
            child: Text(
              'Today\'s menu',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
          ),
          const _UlSection(),
          const _TableSection(),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(color: const Color(0xFFD7CCC8)),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 19.92),
              child: Text(
                'Say hello',
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'Your name',
                style: TextStyle(
                  color: Color(0xFF3E2723),
                  fontSize: 14,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
            CupertinoTextField(placeholder: 'Jane Doe'),
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 4),
              child: Text(
                'Message',
                style: TextStyle(
                  color: Color(0xFF3E2723),
                  fontSize: 14,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
            CupertinoTextField(
              placeholder: 'How can we help?',
              minLines: 3,
              maxLines: 3,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Align(
                alignment: Alignment.topLeft,
                child: CupertinoButton.filled(onPressed: () {}, child: Text('Send')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UlSection extends StatelessWidget {
  const _UlSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                    color: Color(0xFF3E2723),
                    fontFamily: 'Georgia',
                    height: 1.8,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const Expanded(
                child: Text(
                  'Espresso – \$3.00',
                  style: TextStyle(
                    color: Color(0xFF3E2723),
                    fontFamily: 'Georgia',
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
                    color: Color(0xFF3E2723),
                    fontFamily: 'Georgia',
                    height: 1.8,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const Expanded(
                child: Text(
                  'Flat white – \$4.20',
                  style: TextStyle(
                    color: Color(0xFF3E2723),
                    fontFamily: 'Georgia',
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
                    color: Color(0xFF3E2723),
                    fontFamily: 'Georgia',
                    height: 1.8,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const Expanded(
                child: Text(
                  'Cold brew – \$4.50',
                  style: TextStyle(
                    color: Color(0xFF3E2723),
                    fontFamily: 'Georgia',
                    height: 1.8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TableSection extends StatelessWidget {
  const _TableSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEBE9),
                    border: Border.all(color: const Color(0xFFD7CCC8)),
                  ),
                  child: const Text(
                    'Size',
                    style: TextStyle(
                      color: Color(0xFF3E2723),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Georgia',
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFEBE9),
                    border: Border(
                      top: BorderSide(color: Color(0xFFD7CCC8)),
                      right: BorderSide(color: Color(0xFFD7CCC8)),
                      bottom: BorderSide(color: Color(0xFFD7CCC8)),
                    ),
                  ),
                  child: const Text(
                    'Price',
                    style: TextStyle(
                      color: Color(0xFF3E2723),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Georgia',
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFEBE9),
                    border: Border(
                      top: BorderSide(color: Color(0xFFD7CCC8)),
                      right: BorderSide(color: Color(0xFFD7CCC8)),
                      bottom: BorderSide(color: Color(0xFFD7CCC8)),
                    ),
                  ),
                  child: const Text(
                    'Calories',
                    style: TextStyle(
                      color: Color(0xFF3E2723),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Georgia',
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Color(0xFFD7CCC8)),
                      bottom: BorderSide(color: Color(0xFFD7CCC8)),
                      left: BorderSide(color: Color(0xFFD7CCC8)),
                    ),
                  ),
                  child: const Text(
                    'Small',
                    style: TextStyle(color: Color(0xFF3E2723), fontFamily: 'Georgia'),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Color(0xFFD7CCC8)),
                      bottom: BorderSide(color: Color(0xFFD7CCC8)),
                    ),
                  ),
                  child: const Text(
                    '\$3.50',
                    style: TextStyle(color: Color(0xFF3E2723), fontFamily: 'Georgia'),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Color(0xFFD7CCC8)),
                      bottom: BorderSide(color: Color(0xFFD7CCC8)),
                    ),
                  ),
                  child: const Text(
                    '120',
                    style: TextStyle(color: Color(0xFF3E2723), fontFamily: 'Georgia'),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Color(0xFFD7CCC8)),
                      bottom: BorderSide(color: Color(0xFFD7CCC8)),
                      left: BorderSide(color: Color(0xFFD7CCC8)),
                    ),
                  ),
                  child: const Text(
                    'Large',
                    style: TextStyle(color: Color(0xFF3E2723), fontFamily: 'Georgia'),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Color(0xFFD7CCC8)),
                      bottom: BorderSide(color: Color(0xFFD7CCC8)),
                    ),
                  ),
                  child: const Text(
                    '\$4.80',
                    style: TextStyle(color: Color(0xFF3E2723), fontFamily: 'Georgia'),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Color(0xFFD7CCC8)),
                      bottom: BorderSide(color: Color(0xFFD7CCC8)),
                    ),
                  ),
                  child: const Text(
                    '210',
                    style: TextStyle(color: Color(0xFF3E2723), fontFamily: 'Georgia'),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
