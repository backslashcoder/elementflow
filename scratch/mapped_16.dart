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
              padding: const EdgeInsets.all(20),
              color: const Color(0xFFFAFAFA),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'New arrivals',
                      style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
                    ),
                  ),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      Container(
                        width: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              offset: Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              'https://picsum.photos/id/21/320/240',
                              height: 110,
                              fit: BoxFit.cover,
                              webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                              errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(height: 110),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Canvas backpack',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Text(
                                      '\$59',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Arial',
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
                        width: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              offset: Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              'https://picsum.photos/id/96/320/240',
                              height: 110,
                              fit: BoxFit.cover,
                              webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                              errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(height: 110),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Ceramic mug',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Text(
                                      '\$18',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Arial',
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
                        width: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              offset: Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              'https://picsum.photos/id/119/320/240',
                              height: 110,
                              fit: BoxFit.cover,
                              webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                              errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(height: 110),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Desk lamp',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Text(
                                      '\$42',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Arial',
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
                        width: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              offset: Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              'https://picsum.photos/id/160/320/240',
                              height: 110,
                              fit: BoxFit.cover,
                              webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                              errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(height: 110),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Wool throw',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Text(
                                      '\$75',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Arial',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
