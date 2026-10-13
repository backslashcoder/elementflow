import 'package:elementflow/features/converter/models/conversion_result.dart';
import 'package:elementflow/features/converter/models/ui_node.dart';
import 'package:elementflow/features/converter/services/conversion_service.dart';
import 'package:elementflow/features/converter/services/dart_code_generator.dart';
import 'package:elementflow/features/converter/services/sample_html.dart';
import 'package:elementflow/features/converter/services/samples.dart';
import 'package:flutter_test/flutter_test.dart';

ConversionResult conv(String html) => ConversionService().convert(html);
String gen(String html) => DartCodeGenerator().generate(conv(html)).source;

UiNode? find(UiNode n, bool Function(UiNode) test) {
  if (test(n)) return n;
  for (final c in n.children) {
    final f = find(c, test);
    if (f != null) return f;
  }
  for (final s in n.spans) {
    if (s.widget != null) {
      final f = find(s.widget!, test);
      if (f != null) return f;
    }
  }
  return null;
}

void main() {
  test('basic text', () {
    final r = conv('<p>Hello world</p>');
    final t = find(r.root, (n) => n.kind == UiKind.text)!;
    expect(t.spans.single.text, 'Hello world');
    expect(gen('<p>Hello world</p>'), contains("Text('Hello world')"));
  });

  test('nested elements keep structure and inline styling', () {
    final r = conv(
      '<div><section><p>a <b>b</b> <em>c</em></p></section></div>',
    );
    final t = find(r.root, (n) => n.kind == UiKind.text)!;
    expect(t.spans.map((s) => s.text).join(), 'a b c');
    expect(t.spans.any((s) => s.style.weight == 700), isTrue);
    expect(t.spans.any((s) => s.style.italic), isTrue);
  });

  test('css colors: hex, rgb, hsl, named, invalid', () {
    String color(String v) => gen('<p style="color:$v">x</p>');
    expect(color('#ff0000'), contains('Color(0xFFFF0000)'));
    expect(color('rgb(0,128,0)'), contains('Color(0xFF008000)'));
    expect(color('rgba(0,0,0,.5)'), contains('Color(0x80000000)'));
    expect(color('hsl(120, 100%, 50%)'), contains('Color(0xFF00FF00)'));
    expect(color('tomato'), contains('Color(0xFFFF6347)'));
    final bad = conv('<p style="color:notacolor">x</p>');
    expect(
      bad.warnings.any((w) => w.message.contains('Invalid color')),
      isTrue,
    );
  });

  test('font size, weight and family', () {
    final r = conv(
      '<p style="font-size:20px;font-weight:600;font-family:\'Open Sans\',sans-serif">x</p>',
    );
    final t = find(r.root, (n) => n.kind == UiKind.text)!;
    expect(t.textStyle.fontSize, 20);
    expect(t.textStyle.weight, 600);
    expect(t.textStyle.fontFamily, 'Open Sans');
    expect(gen('<h1>T</h1>'), contains('FontWeight.w700'));
  });

  test('padding and margin', () {
    final r = conv(
      '<div style="padding:10px 20px;margin:4px"><p style="margin:0">x</p></div>',
    );
    final d = find(r.root, (n) => n.tag == 'div')!;
    expect(d.box.padding.top, 10);
    expect(d.box.padding.left, 20);
    expect(d.box.margin.left, 4);
  });

  test('border and border radius', () {
    final code = gen(
      '<div style="border:2px solid #333;border-radius:8px;background:#fff">x</div>',
    );
    expect(code, contains('Border.all'));
    expect(code, contains('BorderRadius.circular(8)'));
    expect(code, contains('Clip.antiAlias'));
  });

  test('flex row and column', () {
    final row = conv(
      '<div style="display:flex;gap:8px"><span>a</span><span>b</span></div>',
    );
    expect(find(row.root, (n) => n.kind == UiKind.row)!.gap, 8);
    final col = conv(
      '<div style="display:flex;flex-direction:column"><p>a</p><p>b</p></div>',
    );
    expect(find(col.root, (n) => n.tag == 'div')!.kind, UiKind.column);
    expect(
      gen('<div style="display:flex"><i>a</i><i>b</i></div>'),
      contains('Row('),
    );
  });

  test('alignment, spacing and flex grow', () {
    final code = gen(
      '<div style="display:flex;justify-content:space-between;'
      'align-items:center"><div style="flex:1">a</div><div>b</div></div>',
    );
    expect(code, contains('MainAxisAlignment.spaceBetween'));
    // center is Flutter's default, so it is intentionally not emitted.
    expect(code, isNot(contains('CrossAxisAlignment.stretch')));
    expect(code, contains('Expanded('));
  });

  test('images', () {
    final r = conv(
      '<img src="https://x.test/a.png" width="100" height="50" alt="a">',
    );
    final img = find(r.root, (n) => n.kind == UiKind.image)!;
    expect(img.src, 'https://x.test/a.png');
    expect(img.box.width!.value, 100);
    final code = gen('<img src="https://x.test/a.png" width="100">');
    expect(code, contains('Image.network('));
    expect(code, contains('_ImagePlaceholder'));
    expect(
      conv('<img>').warnings.any((w) => w.message.contains('src')),
      isTrue,
    );
  });

  test('buttons and inputs', () {
    final code = gen(
      '<button style="background:#3f51b5;color:#fff">Go</button>'
      '<input type="text" placeholder="Name"><textarea rows="3"></textarea>'
      '<input type="checkbox" checked>',
    );
    expect(code, contains('ElevatedButton('));
    expect(code, contains("Text('Go')"));
    expect(code, contains("hintText: 'Name'"));
    expect(code, contains('Checkbox('));
    expect(code, contains('minLines: 3'));
  });

  test('special characters are escaped', () {
    final code = gen(r"<p>It's \ $money &amp; &lt;tags&gt; “quotes” 日本</p>");
    expect(code, contains(r"It\'s \\ \$money & <tags> “quotes” 日本"));
  });

  test('malformed html still converts and warns', () {
    final r = conv('<div><p>unclosed <b>bold</div></span><p>after');
    expect(find(r.root, (n) => n.kind == UiKind.text), isNotNull);
    expect(r.warnings.any((w) => w.message.contains('Malformed')), isTrue);
  });

  test('unsupported css produces warnings', () {
    final r = conv(
      '<div style="transform:rotate(3deg);position:absolute;'
      'filter:blur(2px)">x</div>',
    );
    final msgs = r.warnings.map((w) => w.message).join('\n');
    expect(msgs, contains('"transform"'));
    expect(msgs, contains('"filter"'));
    expect(msgs, contains('position: absolute'));
    expect(r.unsupportedFeatures, contains('filter'));
  });

  test('style blocks: selectors, specificity, var(), inheritance', () {
    final r = conv('''
<style>
  :root { --c: #00ff00; }
  p { color: red; } .a { color: var(--c); } #x { font-size: 30px; }
  div > p.a:first-child { font-weight: bold; }
  section { color: blue; }
</style>
<div><p class="a" id="x">one</p></div>
<section><span>inherits</span></section>''');
    final one = find(r.root, (n) => n.spans.any((s) => s.text == 'one'))!;
    expect(one.textStyle.color, 0xFF00FF00);
    expect(one.textStyle.fontSize, 30);
    expect(one.textStyle.weight, 700);
    final inh = find(r.root, (n) => n.spans.any((s) => s.text == 'inherits'))!;
    expect(inh.textStyle.color, 0xFF0000FF);
  });

  test('errors for empty and non-html input', () {
    expect(() => conv('   '), throwsA(isA<ConversionException>()));
    expect(() => conv('just text'), throwsA(isA<ConversionException>()));
  });

  test('conversion is deterministic', () {
    expect(gen(landingPageSample), gen(landingPageSample));
  });

  test('there are twenty samples', () => expect(htmlSamples.length, 20));

  test('generated code is self-contained', () {
    for (final html in [for (final s in htmlSamples) s.html]) {
      final code = gen(html);
      expect(code, contains("import 'package:flutter/material.dart';"));
      expect(code, contains('void main()'));
      expect(code, contains('MaterialApp('));
      expect(code, isNot(contains('UiNode')));
      expect(code, isNot(contains('elementflow')));
      expect('{'.allMatches(code).length, '}'.allMatches(code).length);
      expect('('.allMatches(code).length, ')'.allMatches(code).length);
    }
  });
}
