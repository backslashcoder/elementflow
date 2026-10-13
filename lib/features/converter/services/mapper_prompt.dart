import 'mapper_samples.dart';

/// Template variables, shared by the mapper dialog and the AI prompt so the
/// documentation cannot drift apart.
const mapperVariableDocs = <(String, String)>[
  ('{{text}}', 'Text content of the element as a non-null Dart string literal'),
  (
    '{{child}}',
    'Converted inner content as one widget (needs "children": "child")',
  ),
  (
    '{{children}}',
    'Converted inner content as a list of widgets (needs "children": "children")',
  ),
  (
    '{{placeholder}} {{value}} {{href}} {{src}} {{alt}} {{id}} {{name}} {{type}} {{title}} {{class}}',
    'Attribute value as a Dart string literal, or null when the attribute is absent',
  ),
  (
    '{{attr.NAME}}',
    'Any attribute, e.g. {{attr.data-variant}} (string or null)',
  ),
  (
    '{{checked}} {{disabled}} {{required}} {{readonly}} {{selected}} {{multiple}}',
    'true / false from the attribute',
  ),
  ('{{bool.NAME}}', 'Any attribute as true / false'),
  (
    '{{options}} {{selectedOption}} {{selectedIndex}}',
    'For <select>: list of option labels, the initial option (String) and its index',
  ),
  (
    '{{style.color}} {{style.backgroundColor}} {{style.fontSize}} {{style.fontWeight}}',
    'Computed CSS as Dart: Color(...), a number, FontWeight.wNNN. backgroundColor may be null',
  ),
  (
    '{{style.padding}} {{style.borderRadius}} {{style.width}} {{style.height}} {{style.textAlign}} {{style.gap}}',
    'EdgeInsets, numbers (width and height may be null), TextAlign (may be null)',
  ),
];

/// A complete prompt a user can give to an AI assistant (with access to their
/// component library) to produce a mapper file for ElementFlow.
String buildMapperPrompt() {
  final vars = mapperVariableDocs.map((v) => '- `${v.$1}`: ${v.$2}').join('\n');
  return '''
You are helping me connect my Flutter component library to ElementFlow, a tool that converts HTML and CSS into Flutter code. ElementFlow reads a JSON "component mapper" that says which of MY widgets replace which HTML elements, so the generated Dart code uses my design system instead of stock Flutter widgets.

Your task: inspect my component library and produce ONE mapper JSON file.

## My component library
[PASTE HERE: the widget source files, an API listing, a design-system doc, or point me to the folder you can read. Include constructor signatures, required parameters, variants/enums and the package import path.]

## How to work
1. Make an inventory of my reusable widgets and their real constructors (names, named constructors, required and optional parameters, parameter types).
2. Decide which HTML element or class pattern each widget corresponds to. Cover, where my library has an equivalent: buttons (and their variants), text inputs (text, email, password, search, number), textarea, select, checkbox, radio, switch/slider, headings h1-h6, paragraphs/text, links, images, dividers (hr), lists, cards/containers (a `.card` class is typical), badges/chips/tags, alerts, navigation bars, and layout wrappers.
3. Write one component rule per mapping. Only use constructors and parameters that really exist in my code. Never invent a widget or parameter. Skip an HTML element if I have no equivalent (ElementFlow then uses the standard Flutter widget).
4. Prefer specific selectors for variants (for example `button.secondary` is more specific than `button`, and the most specific matching rule wins; for equal specificity the later rule wins).
5. Check every template variable and every parameter type against the rules below, then output the file.

## Output
Reply with ONLY the JSON file contents: no explanation, no comments, no markdown code fences. After the JSON, nothing else. (If something is unclear, make a sensible choice rather than asking.)

## File format
Top-level keys:
- `name` (string, required in practice): display name.
- `description` (string, optional).
- `imports` (list of strings, optional): libraries the generated file must import, as `package:...` or `dart:...` paths. Do not include `package:flutter/material.dart` (always imported).
- `theme` (string, optional): a Dart expression used as `MaterialApp.theme`, for example `MyTheme.light()`.
- `declarations` (list of strings, optional): Dart source appended to the generated file. Only use this for small helper widgets/enums that do not exist in my library (for example a stateful wrapper). They live in the same file, so do not add imports or `part` directives inside them.
- `components` (non-empty list, required): the rules.

Each component rule:
- `selector` (string, required): a CSS selector for the HTML element. Supported: tag, `.class`, `#id`, `[attr]`, `[attr=value]`, `^=`, `\$=`, `*=` attribute selectors, descendant (space) and child (`>`) combinators, comma lists, `:first-child`, `:last-child`, `:nth-child(n)`, `:not(<simple selector>)`. Not supported: `:hover`/`:focus`-style states and pseudo-elements.
- `widget` (string, required): the class or named constructor to call, for example `MyButton`, `MyButton.primary` or `MyDropdown<String>`.
- `positional` (list of strings, optional): positional arguments, in order.
- `args` (object, optional): named arguments. Every value is a STRING containing a Dart EXPRESSION, copied into the code as is. Examples: `"onPressed": "() {}"`, `"obscure": "true"`, `"kind": "MyButtonKind.ghost"`, `"label": "{{text}}"`, `"child": "Padding(padding: const EdgeInsets.all(16), child: {{child}})"`.
- `children` (string, optional): `none` (default), `child` or `children`. Must be `child` if any template uses `{{child}}` and `children` if any uses `{{children}}`.
- `box` (string, optional): which parts of the element's CSS box still wrap your widget: `none` (the widget draws everything), `margin` (default: keep outer spacing), `size` (margin plus width/height) or `all`. Use `none` or `margin` for design-system widgets that style themselves.
- `description` (string, optional).

## Template variables
Templates may contain `{{variable}}` placeholders, replaced by Dart source. Only these exist; anything else is rejected:
$vars

Typing rules:
- `{{text}}` is always a non-null `String` literal. Attribute variables (`{{placeholder}}`, `{{value}}`, `{{href}}`, `{{src}}` ...) may be `null`: the target parameter must be nullable (`String?`), or you must provide a fallback inside the expression such as `({{placeholder}} ?? '')` only when the target needs a non-null string.
- `{{checked}}`, `{{disabled}}` ... are `bool`.
- `{{style.backgroundColor}}`, `{{style.width}}`, `{{style.height}}` and `{{style.textAlign}}` may be `null`: only pass them to nullable parameters.
- Callbacks such as `onPressed`/`onChanged`/`onTap` should be `() {}` or `(_) {}` unless my widget makes them optional.
- Stateful controls (checkbox, switch, dropdown, radio) must stay interactive. If my widget is stateless and needs the value managed by a parent, add a small stateful wrapper in `declarations` and map to that wrapper.
- `BuildContext` is available as `context` inside any expression, so `Theme.of(context)` and `MyTheme.of(context)` work.

## Example
$mapperTemplate

## Final self-check (do this before answering)
- The output is a single valid JSON object that starts with `{` and ends with `}`.
- Every `selector` is a valid CSS selector without hover/focus pseudo-classes.
- Every `widget` and every argument name exists in my library with a compatible type.
- Every `{{variable}}` is in the list above; `children` matches the use of `{{child}}` / `{{children}}`.
- Strings inside `args` are valid Dart expressions (quotes and escaping are valid inside the JSON strings).
- Every library the widgets need is listed in `imports`.
''';
}
