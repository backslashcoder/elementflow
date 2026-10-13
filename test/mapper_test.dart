import 'dart:io';

import 'package:elementflow/features/converter/cubit/converter_cubit.dart';
import 'package:elementflow/features/converter/models/component_mapper.dart';
import 'package:elementflow/features/converter/services/conversion_service.dart';
import 'package:elementflow/features/converter/services/dart_code_generator.dart';
import 'package:elementflow/features/converter/services/mapper_prompt.dart';
import 'package:elementflow/features/converter/services/mapper_samples.dart';
import 'package:elementflow/features/converter/services/samples.dart';
import 'package:flutter_test/flutter_test.dart';

String gen(String html, ComponentMapper? mapper) => DartCodeGenerator()
    .generate(ConversionService().convert(html, mapper: mapper))
    .source;

ComponentMapper mapper(String json) => ComponentMapper.parse(json);

const form = '''
<h1>Welcome</h1>
<div class="card"><p>inside card</p></div>
<input type="text" placeholder="Name">
<input type="password" placeholder="Secret">
<input type="checkbox" checked>
<select><option>One</option><option selected>Two</option></select>
<button>Save</button><button class="ghost">Cancel</button>
<span class="tag" style="background:#ff0000;padding:2px 8px">new</span>
''';

void main() {
  group('parsing and validation', () {
    test('all sample mappers are valid', () {
      for (final s in mapperSamples) {
        expect(s.parse().components, isNotEmpty, reason: s.name);
      }
      expect(mapperSamples.length, 3);
      expect(ComponentMapper.parse(mapperTemplate).components, hasLength(2));
    });

    test('reports every problem', () {
      try {
        mapper('''{"components":[
          {"selector":"","widget":"1bad"},
          {"selector":"button","widget":"B","args":{"a":"{{nope}}"}},
          {"selector":"div","widget":"D","args":{"c":"{{child}}"}}
        ]}''');
        fail('should throw');
      } on MapperException catch (e) {
        final all = e.errors.join('\n');
        expect(all, contains('"selector"'));
        expect(all, contains('"widget"'));
        expect(all, contains('{{nope}}'));
        expect(all, contains('"children" is "none"'));
      }
    });

    test('rejects invalid json and wrong shapes', () {
      expect(() => mapper('not json'), throwsA(isA<MapperException>()));
      expect(() => mapper('[]'), throwsA(isA<MapperException>()));
      expect(
        () => mapper('{"components":[]}'),
        throwsA(isA<MapperException>()),
      );
      expect(
        () => mapper(
          '{"imports":["http://x"],"components":[{"selector":"a","widget":"A"}]}',
        ),
        throwsA(isA<MapperException>()),
      );
    });
  });

  group('conversion', () {
    final acme = mapperSamples[2].parse();

    test('uses the custom widgets and declares them', () {
      final code = gen(form, acme);
      expect(code, contains("AcmeHeading('Welcome', level: 1)"));
      expect(code, contains("AcmeField(hint: 'Name')"));
      expect(code, contains("AcmeField(hint: 'Secret', obscure: true)"));
      expect(code, contains('AcmeCheck(initial: true)'));
      expect(code, contains("AcmeButton(label: 'Save'"));
      expect(code, contains('AcmeButtonKind.ghost'));
      expect(code, contains('AcmeCard('));
      expect(code, contains('class AcmeButton extends StatelessWidget'));
      expect(code, contains('colorSchemeSeed: const Color(0xFF7C3AED)'));
      // The standard widgets for mapped elements are gone.
      expect(code, isNot(contains('ElevatedButton(')));
      expect(code, isNot(contains("hintText: 'Name'")));
    });

    test('style variables are passed through', () {
      final code = gen(form, acme);
      expect(
        code,
        contains("AcmeBadge(label: 'new', color: Color(0xFFFF0000))"),
      );
    });

    test('more specific selector wins', () {
      final code = gen('<button class="ghost">X</button>', acme);
      expect(code, contains('AcmeButtonKind.ghost'));
    });

    test('imports are added only when the mapper is used', () {
      final cup = mapperSamples[1].parse();
      expect(
        gen(form, cup),
        contains("import 'package:flutter/cupertino.dart';"),
      );
      final unused = gen('<p>no mapped elements</p>', cup);
      expect(unused, isNot(contains('cupertino')));
      expect(unused, isNot(contains('CupSwitch')));
    });

    test('children variables embed converted content', () {
      final code = gen(
        '<div class="card"><p>hello</p><p>world</p></div>',
        acme,
      );
      expect(code, contains('AcmeCard('));
      expect(code, contains("Text('hello')"));
      expect(code, contains("Text('world')"));
    });

    test('mapper matching nothing is reported', () {
      final r = ConversionService().convert('<p>x</p>', mapper: acme);
      expect(r.mappedCount, 0);
      expect(
        r.warnings.any((w) => w.message.contains('matched no elements')),
        isTrue,
      );
    });

    test('report counts mapped elements', () {
      final r = ConversionService().convert(form, mapper: acme);
      expect(r.mappedWidgets['AcmeField'], 2);
      expect(r.mappedCount, greaterThan(5));
    });

    test('generic widget names and selects', () {
      final code = gen(form, mapperSamples[0].parse());
      expect(code, contains('DropdownMenu<String>('));
      expect(code, contains("initialSelection: 'Two'"));
      expect(code, contains("['One', 'Two']"));
    });

    test('without a mapper nothing changes', () {
      expect(gen(form, null), contains('ElevatedButton('));
    });
  });

  group('AI prompt', () {
    test('documents only variables the validator accepts', () {
      final prompt = buildMapperPrompt();
      for (final (names, _) in mapperVariableDocs) {
        for (final m in templateVariable.allMatches(names)) {
          final v = m.group(1)!;
          final concrete = v.replaceAll('NAME', 'example');
          expect(isKnownMapperVariable(concrete), isTrue, reason: v);
          expect(prompt, contains('{{$v}}'));
        }
      }
    });

    test(
      'contains the format, an example that parses, and the placeholder',
      () {
        final prompt = buildMapperPrompt();
        expect(prompt, contains(mapperTemplate));
        expect(ComponentMapper.parse(mapperTemplate).components, isNotEmpty);
        expect(prompt, contains('[PASTE HERE'));
        for (final key in [
          'selector',
          'widget',
          'positional',
          'args',
          'children',
          'box',
          'imports',
          'theme',
          'declarations',
        ]) {
          expect(prompt, contains('`$key`'), reason: key);
        }
        expect(prompt, contains(r'`$=`'), reason: 'escaped dollar rendered');
      },
    );

    test('copyMapperPrompt reports success', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final cubit = ConverterCubit();
      addTearDown(cubit.close);
      await cubit.copyMapperPrompt();
      expect(cubit.state.feedback?.isError, isFalse);
      expect(cubit.state.feedback?.message, contains('Prompt copied'));
    });
  });

  group('cubit', () {
    test('loads, rejects and tracks outdated state', () async {
      final cubit = ConverterCubit();
      addTearDown(cubit.close);
      cubit.updateHtml(form);
      await cubit.convertToFlutter();
      expect(cubit.state.isOutdated, isFalse);

      expect(cubit.loadMapperText(mapperSamples[2].json), isTrue);
      expect(cubit.state.mapper?.name, 'Acme UI (custom library)');
      expect(cubit.state.isOutdated, isTrue, reason: 'mapper changed');

      await cubit.convertToFlutter();
      expect(cubit.state.isOutdated, isFalse);
      expect(cubit.state.dartSource, contains('AcmeButton'));

      // An invalid mapper is rejected and the active one stays.
      expect(cubit.loadMapperText('{"components":[{"widget":"X"}]}'), isFalse);
      expect(cubit.state.mapper?.name, 'Acme UI (custom library)');
      expect(cubit.state.mapperErrors, isNotEmpty);
      expect(cubit.state.feedback?.isError, isTrue);

      cubit.clearMapper();
      expect(cubit.state.mapper, isNull);
      expect(cubit.state.isOutdated, isTrue);
    });
  });

  // Dumps mapped output so it can be analyzed with `dart analyze`.
  test('dump mapped code', () {
    final dir = Directory(Platform.environment['EF_DUMP_DIR'] ?? '');
    if (dir.path.isEmpty) return;
    dir.createSync(recursive: true);
    var i = 0;
    for (final m in mapperSamples) {
      final cm = m.parse();
      for (final s in [form, ...htmlSamples.take(8).map((s) => s.html)]) {
        File('${dir.path}/mapped_${i++}.dart').writeAsStringSync(gen(s, cm));
      }
    }
  });
}
