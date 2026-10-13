import 'package:flutter/material.dart';

import 'app.dart';
import 'features/converter/widgets/flutter_preview_panel.dart';

void main() {
  final previousHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    // Layout problems in the converted preview (e.g. overflows) are shown in
    // the preview panel in addition to the normal console report.
    PreviewErrors.report(details);
    (previousHandler ?? FlutterError.presentError)(details);
  };
  runApp(const ElementFlowApp());
}
