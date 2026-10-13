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
    return const Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: DefaultTextStyle(
        style: TextStyle(
          color: Color(0xFF000000),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        child: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.all(8), child: _ArticleSection()),
        ),
      ),
    );
  }
}

class _ArticleSection extends StatelessWidget {
  const _ArticleSection();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 688),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'DESIGN',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontSize: 12,
                fontFamily: 'Arial',
                letterSpacing: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: AcmeHeading('Why small interfaces feel faster', level: 1),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 5, bottom: 13),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 13,
                    fontFamily: 'Arial',
                  ),
                  children: [
                    TextSpan(text: 'By '),
                    TextSpan(
                      text: 'Mira Patel',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: ' · 6 min read'),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                'https://picsum.photos/id/180/800/400',
                height: 200,
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(height: 200),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    color: Color(0xFF212121),
                    fontSize: 18,
                    fontFamily: 'Georgia',
                    height: 1.7,
                  ),
                  children: [
                    const TextSpan(text: 'Speed is partly '),
                    const TextSpan(
                      text: 'perception',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const TextSpan(
                      text: '. When a screen shows only what matters, people decide sooner and ',
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        color: const Color(0xFFFFF59D),
                        child: const Text(
                          'trust the result',
                          style: TextStyle(
                            color: Color(0xFF212121),
                            fontSize: 18,
                            fontFamily: 'Georgia',
                            height: 1.7,
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: ' more.'),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              margin: const EdgeInsets.only(top: 2, bottom: 20),
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Color(0xFFE53935), width: 4)),
              ),
              child: const Text(
                'Remove everything that does not help the next decision.',
                style: TextStyle(
                  color: Color(0xFF616161),
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 19.92),
              child: AcmeHeading('Three habits', level: 2),
            ),
            const _OlSection(),
            const Padding(
              padding: EdgeInsets.only(top: 7, bottom: 24),
              child: Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 14,
                    fontFamily: 'Arial',
                  ),
                  children: [
                    TextSpan(text: 'Thanks for reading. '),
                    TextSpan(
                      text: 'Subscribe',
                      style: TextStyle(
                        color: Color(0xFF0000EE),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(text: ' for more.'),
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

class _OlSection extends StatelessWidget {
  const _OlSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16),
      margin: const EdgeInsets.only(bottom: 17),
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
                  '1.',
                  style: TextStyle(
                    color: Color(0xFF212121),
                    fontSize: 17,
                    fontFamily: 'Georgia',
                    height: 1.8,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const Expanded(
                child: Text(
                  'Show one primary action per screen.',
                  style: TextStyle(
                    color: Color(0xFF212121),
                    fontSize: 17,
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
                  '2.',
                  style: TextStyle(
                    color: Color(0xFF212121),
                    fontSize: 17,
                    fontFamily: 'Georgia',
                    height: 1.8,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const Expanded(
                child: Text(
                  'Prefer defaults over settings.',
                  style: TextStyle(
                    color: Color(0xFF212121),
                    fontSize: 17,
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
                  '3.',
                  style: TextStyle(
                    color: Color(0xFF212121),
                    fontSize: 17,
                    fontFamily: 'Georgia',
                    height: 1.8,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const Expanded(
                child: Text(
                  'Measure the time to first decision.',
                  style: TextStyle(
                    color: Color(0xFF212121),
                    fontSize: 17,
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
