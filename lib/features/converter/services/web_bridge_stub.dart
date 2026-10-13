import 'package:flutter/material.dart';

/// Non-web fallback: ElementFlow only runs on Flutter Web, so this exists to
/// keep tests and tooling on other platforms compiling.
class HtmlFrame extends StatelessWidget {
  const HtmlFrame({
    super.key,
    required this.html,
    this.viewportWidth = 390,
    this.viewportHeight = 800,
    this.scale = 1,
  });

  final String html;
  final double viewportWidth, viewportHeight, scale;

  @override
  Widget build(BuildContext context) => const Center(
    child: Text('HTML preview is only available on Flutter Web.'),
  );
}

/// Returns false: downloads are only supported in the browser.
bool downloadTextFile(String filename, String content) => false;

/// Prepares user HTML for display inside the sandboxed iframe.
String prepareFrameHtml(String html) => html;
