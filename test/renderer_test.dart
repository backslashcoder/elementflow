import 'dart:io';

import 'package:elementflow/features/converter/services/conversion_service.dart';
import 'package:elementflow/features/converter/services/dart_code_generator.dart';
import 'package:elementflow/features/converter/services/samples.dart';
import 'package:elementflow/features/converter/widgets/ui_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final samples = {for (final s in htmlSamples) s.name: s.html};

  for (final e in samples.entries) {
    testWidgets('preview renders "${e.key}" without errors', (tester) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final result = ConversionService().convert(e.value);
      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: (c) => UiRenderer.page(c, result))),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('checkbox, radio and select respond to taps', (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final result = ConversionService().convert(
      '<input type="checkbox"> <input type="radio" name="g" checked>'
      '<input type="radio" name="g">'
      '<select><option>One</option><option>Two</option></select>',
    );
    await tester.pumpWidget(
      MaterialApp(home: Builder(builder: (c) => UiRenderer.page(c, result))),
    );
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    await tester.tap(find.byIcon(Icons.radio_button_unchecked));
    await tester.pump();
    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);

    expect(find.text('One'), findsOneWidget);
    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Two').last);
    await tester.pumpAndSettle();
    expect(find.text('Two'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Dumps generated code so it can be analyzed with `dart analyze`.
  test('dump generated code', () {
    final dir = Directory(Platform.environment['EF_DUMP_DIR'] ?? '');
    if (dir.path.isEmpty) return;
    dir.createSync(recursive: true);
    var i = 0;
    for (final html in samples.values) {
      final code = DartCodeGenerator()
          .generate(ConversionService().convert(html))
          .source;
      File('${dir.path}/page_${i++}.dart').writeAsStringSync(code);
    }
  });
}
