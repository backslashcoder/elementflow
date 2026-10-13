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
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 362),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      offset: Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(48)),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          'https://picsum.photos/id/64/200/200',
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                          errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(width: 96, height: 96),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Text(
                        'Ada Lovelace',
                        style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                      ),
                    ),
                    const Text(
                      'Mathematician & writer',
                      style: TextStyle(color: Color(0xFF757575), fontFamily: 'Arial'),
                      textAlign: TextAlign.center,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Wrote the first published algorithm intended for a machine.',
                        style: TextStyle(
                          color: Color(0xFF424242),
                          fontSize: 14,
                          fontFamily: 'Arial',
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: CupertinoButton.filled(
                        onPressed: () {},
                        child: Text('Follow'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 120,
      height: height ?? 90,
      color: const Color(0xFFEEEEEE),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFF9E9E9E),
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
