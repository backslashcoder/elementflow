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
              child: AcmeHeading('Create your account', level: 1),
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
            AcmeField(hint: 'Jane Doe'),
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 4),
              child: Text(
                'Email',
                style: TextStyle(fontSize: 13, fontFamily: 'Arial'),
              ),
            ),
            AcmeField(hint: 'jane@example.com'),
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 4),
              child: Text(
                'Password',
                style: TextStyle(fontSize: 13, fontFamily: 'Arial'),
              ),
            ),
            AcmeField(hint: 'At least 8 characters', obscure: true),
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
                      child: AcmeCheck(initial: true),
                    ),
                    const TextSpan(text: ' I agree to the terms'),
                  ],
                ),
              ),
            ),
            AcmeButton(label: 'Create account', onPressed: () {}),
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
