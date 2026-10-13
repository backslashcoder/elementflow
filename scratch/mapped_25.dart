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
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF7C3AED)),
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
                    child: AcmeHeading('New arrivals', level: 1),
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
}
