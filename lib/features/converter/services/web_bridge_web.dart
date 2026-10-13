import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Content-Security-Policy injected into every previewed document: no
/// scripts, plugins or nested frames; images, fonts and styles are allowed.
const _csp =
    "default-src 'none'; img-src * data: blob:; "
    "style-src * 'unsafe-inline'; font-src * data:; media-src * data: blob:";

/// Prepares user HTML for the sandboxed iframe: forces standards mode,
/// injects the CSP and makes link clicks inert (`<base target=_blank>` in a
/// sandbox without `allow-popups` opens nothing).
String prepareFrameHtml(String html) {
  const injected =
      '<meta http-equiv="Content-Security-Policy" content="$_csp">'
      '<base target="_blank">';
  var out = html;
  final head = RegExp(r'<head[^>]*>', caseSensitive: false).firstMatch(out);
  if (head != null) {
    out = out.replaceRange(head.end, head.end, injected);
  } else {
    final htmlTag = RegExp(
      r'<html[^>]*>',
      caseSensitive: false,
    ).firstMatch(out);
    if (htmlTag != null) {
      out = out.replaceRange(
        htmlTag.end,
        htmlTag.end,
        '<head>$injected</head>',
      );
    } else {
      out = '<head>$injected</head>$out';
    }
  }
  if (!RegExp(r'^\s*<!doctype', caseSensitive: false).hasMatch(out)) {
    out = '<!DOCTYPE html>$out';
  }
  return out;
}

/// Renders [html] in a sandboxed `<iframe srcdoc>`. The sandbox attribute is
/// empty: no scripts, forms, popups, same-origin access or top navigation.
///
/// The iframe behaves like a [viewportWidth] x [viewportHeight] device and is
/// scaled by [scale] to fit its parent, so the page sees a phone, tablet or
/// desktop width.
class HtmlFrame extends StatefulWidget {
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
  State<HtmlFrame> createState() => _HtmlFrameState();
}

class _HtmlFrameState extends State<HtmlFrame> {
  web.HTMLIFrameElement? _iframe;
  String? _appliedHtml;

  @override
  void didUpdateWidget(HtmlFrame old) {
    super.didUpdateWidget(old);
    _apply();
  }

  void _apply() {
    final frame = _iframe;
    if (frame == null) return;
    frame.style
      ..width = '${widget.viewportWidth}px'
      ..height = '${widget.viewportHeight}px'
      ..transformOrigin = '0 0'
      ..transform = 'scale(${widget.scale})';
    if (_appliedHtml != widget.html) {
      _appliedHtml = widget.html;
      frame.srcdoc = prepareFrameHtml(widget.html).toJS;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'iframe',
      onElementCreated: (Object element) {
        final frame = element as web.HTMLIFrameElement;
        frame.setAttribute('sandbox', '');
        frame.setAttribute('referrerpolicy', 'no-referrer');
        frame.setAttribute('title', 'HTML preview');
        frame.style
          ..border = 'none'
          ..backgroundColor = '#ffffff';
        _iframe = frame;
        _apply();
      },
    );
  }
}

/// Saves [content] as a file via a temporary object URL. Returns false when
/// the browser refuses.
bool downloadTextFile(String filename, String content) {
  try {
    final blob = web.Blob(
      [content.toJS].toJS,
      web.BlobPropertyBag(type: 'text/plain;charset=utf-8'),
    );
    final url = web.URL.createObjectURL(blob);
    final a = web.document.createElement('a') as web.HTMLAnchorElement
      ..href = url
      ..download = filename
      ..style.display = 'none';
    web.document.body!.append(a);
    a.click();
    a.remove();
    web.URL.revokeObjectURL(url);
    return true;
  } catch (_) {
    return false;
  }
}
