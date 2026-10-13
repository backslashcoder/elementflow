import 'dart:convert';

import 'package:html/dom.dart' as dom;

import '../services/css_parser_service.dart';
import '../services/selector_matcher.dart';

/// How the converted content of a matched element is passed to the widget.
enum MapperChildren { none, child, children }

/// Which parts of the element's CSS box still wrap the custom widget.
/// `none`: the widget handles its own look. `margin`: keep outer spacing.
/// `size`: margin plus width/height/constraints. `all`: everything.
enum MapperBox { none, margin, size, all }

final templateVariable = RegExp(r'\{\{\s*([A-Za-z][\w.\-]*)\s*\}\}');

/// Variables a template may use. `attr.NAME` and `bool.NAME` accept any name.
const _fixedVariables = {
  'text',
  'child',
  'children',
  'options',
  'selectedIndex',
  'selectedOption',
  'id',
  'class',
  'href',
  'src',
  'alt',
  'placeholder',
  'value',
  'name',
  'type',
  'title',
  'checked',
  'disabled',
  'required',
  'readonly',
  'selected',
  'multiple',
  'style.color',
  'style.backgroundColor',
  'style.fontSize',
  'style.fontWeight',
  'style.padding',
  'style.borderRadius',
  'style.width',
  'style.height',
  'style.textAlign',
  'style.gap',
};

bool isKnownMapperVariable(String v) =>
    _fixedVariables.contains(v) ||
    (v.startsWith('attr.') && v.length > 5) ||
    (v.startsWith('bool.') && v.length > 5);

/// Variables resolved from the element itself (everything except the
/// converted content, which the generator renders).
bool isContentVariable(String v) => v == 'child' || v == 'children';

/// One rule: elements matching [selectors] become [widget].
class ComponentDef {
  ComponentDef({
    required this.selectorText,
    required this.selectors,
    required this.widget,
    required this.positional,
    required this.args,
    required this.children,
    required this.box,
    required this.variables,
    this.description,
  });

  final String selectorText;
  final List<CompiledSelector> selectors;

  /// Widget class or named constructor, e.g. `AcmeButton` or `AcmeButton.primary`.
  final String widget;
  final List<String> positional;
  final Map<String, String> args;
  final MapperChildren children;
  final MapperBox box;
  final String? description;

  /// Every `{{variable}}` used by the templates.
  final Set<String> variables;

  /// Highest specificity among matching selectors, or -1 when none match.
  int matchSpecificity(dom.Element el) {
    var best = -1;
    for (final s in selectors) {
      if (s.matches(el) && s.specificity > best) best = s.specificity;
    }
    return best;
  }
}

class MapperException implements Exception {
  const MapperException(this.errors);
  final List<String> errors;

  @override
  String toString() => errors.join('\n');
}

/// A user-supplied (or sample) mapping from HTML elements to the widgets of
/// their own component library.
class ComponentMapper {
  ComponentMapper._({
    required this.name,
    required this.description,
    required this.imports,
    required this.theme,
    required this.declarations,
    required this.components,
    required this.source,
  });

  final String name;
  final String? description;

  /// `package:` / `dart:` libraries imported by the generated file.
  final List<String> imports;

  /// Dart expression used as `MaterialApp.theme`, if any.
  final String? theme;

  /// Dart source appended to the generated file (helper widgets, enums...).
  final List<String> declarations;
  final List<ComponentDef> components;

  /// Original JSON text (kept for display, download and change detection).
  final String source;

  /// The best matching rule for [el]; later rules win ties.
  ComponentDef? match(dom.Element el) {
    ComponentDef? best;
    var bestSpec = -1;
    for (final c in components) {
      final s = c.matchSpecificity(el);
      if (s >= 0 && s >= bestSpec) {
        best = c;
        bestSpec = s;
      }
    }
    return best;
  }

  static final _widgetName = RegExp(
    r'^[A-Za-z_]\w*(<[\w<>?, ]+>)?(\.[A-Za-z_]\w*)*$',
  );
  static final _importPath = RegExp(r'^(package|dart):[\w./\-]+$');

  /// Parses and validates mapper JSON. Throws [MapperException] listing every
  /// problem found.
  static ComponentMapper parse(String text) {
    final errors = <String>[];
    Object? data;
    try {
      data = jsonDecode(text);
    } on FormatException catch (e) {
      throw MapperException(['The file is not valid JSON: ${e.message}']);
    }
    if (data is! Map<String, dynamic>) {
      throw const MapperException(['The mapper must be a JSON object.']);
    }

    final name = (data['name'] as Object?)?.toString().trim();
    final imports = <String>[];
    final rawImports = data['imports'];
    if (rawImports != null) {
      if (rawImports is! List) {
        errors.add('"imports" must be a list of strings.');
      } else {
        for (final i in rawImports) {
          final v = i is String
              ? (RegExp(r'''^\s*import\s+['"](.+?)['"]''')
                        .firstMatch(i)
                        ?.group(1) ??
                    i.trim())
              : '';
          if (_importPath.hasMatch(v)) {
            if (!imports.contains(v)) imports.add(v);
          } else {
            errors.add(
              'Invalid import "$i": use "package:..." or "dart:..." paths.',
            );
          }
        }
      }
    }

    final declarations = <String>[];
    final rawDecl = data['declarations'];
    if (rawDecl != null) {
      if (rawDecl is! List || rawDecl.any((d) => d is! String)) {
        errors.add('"declarations" must be a list of Dart source strings.');
      } else {
        declarations.addAll(
          rawDecl
              .cast<String>()
              .map((d) => d.trim())
              .where((d) => d.isNotEmpty),
        );
      }
    }

    String? theme;
    if (data['theme'] != null) {
      if (data['theme'] is String &&
          (data['theme'] as String).trim().isNotEmpty) {
        theme = (data['theme'] as String).trim();
      } else {
        errors.add('"theme" must be a Dart expression string.');
      }
    }

    final components = <ComponentDef>[];
    final rawComponents = data['components'];
    if (rawComponents is! List || rawComponents.isEmpty) {
      errors.add('"components" must be a non-empty list.');
    } else {
      for (var i = 0; i < rawComponents.length; i++) {
        final def = _parseComponent(rawComponents[i], i + 1, errors);
        if (def != null) components.add(def);
      }
    }

    if (errors.isNotEmpty) throw MapperException(errors);
    return ComponentMapper._(
      name: name == null || name.isEmpty ? 'Unnamed mapper' : name,
      description: (data['description'] as Object?)?.toString(),
      imports: imports,
      theme: theme,
      declarations: declarations,
      components: components,
      source: text,
    );
  }

  static ComponentDef? _parseComponent(
    Object? raw,
    int n,
    List<String> errors,
  ) {
    final at = 'Component #$n';
    if (raw is! Map<String, dynamic>) {
      errors.add('$at must be an object.');
      return null;
    }
    final before = errors.length;

    final selectorText = raw['selector'];
    final selectors = <CompiledSelector>[];
    if (selectorText is! String || selectorText.trim().isEmpty) {
      errors.add('$at: "selector" (a CSS selector) is required.');
    } else {
      final parsed = CssParserService().parse('$selectorText { color: red }');
      for (final r in parsed.rules) {
        selectors.add(r.selector);
      }
      for (final m in parsed.messages) {
        errors.add('$at: selector "$selectorText": $m');
      }
      if (selectors.isEmpty && parsed.messages.isEmpty) {
        errors.add('$at: selector "$selectorText" could not be understood.');
      }
    }

    final widget = raw['widget'];
    if (widget is! String || !_widgetName.hasMatch(widget.trim())) {
      errors.add(
        '$at: "widget" must be a class or constructor name such as '
        '"AcmeButton" or "AcmeButton.primary".',
      );
    }

    final positional = <String>[];
    final rawPos = raw['positional'];
    if (rawPos != null) {
      if (rawPos is List && rawPos.every((p) => p is String)) {
        positional.addAll(rawPos.cast<String>());
      } else {
        errors.add(
          '$at: "positional" must be a list of Dart expression strings.',
        );
      }
    }

    final args = <String, String>{};
    final rawArgs = raw['args'];
    if (rawArgs != null) {
      if (rawArgs is Map<String, dynamic>) {
        for (final e in rawArgs.entries) {
          if (!RegExp(r'^[A-Za-z_]\w*$').hasMatch(e.key)) {
            errors.add('$at: "${e.key}" is not a valid argument name.');
          } else if (e.value is String) {
            args[e.key] = e.value as String;
          } else if (e.value is bool || e.value is num) {
            args[e.key] = '${e.value}';
          } else {
            errors.add(
              '$at: argument "${e.key}" must be a string (a Dart expression).',
            );
          }
        }
      } else {
        errors.add('$at: "args" must be an object.');
      }
    }

    final children = switch ((raw['children'] as Object?)?.toString()) {
      null || 'none' => MapperChildren.none,
      'child' => MapperChildren.child,
      'children' => MapperChildren.children,
      final v => () {
        errors.add(
          '$at: "children" must be "none", "child" or "children" (got "$v").',
        );
        return MapperChildren.none;
      }(),
    };
    final box = switch ((raw['box'] as Object?)?.toString()) {
      null || 'margin' => MapperBox.margin,
      'none' => MapperBox.none,
      'size' => MapperBox.size,
      'all' => MapperBox.all,
      final v => () {
        errors.add(
          '$at: "box" must be "none", "margin", "size" or "all" (got "$v").',
        );
        return MapperBox.margin;
      }(),
    };

    final variables = <String>{};
    for (final t in [...positional, ...args.values]) {
      for (final m in templateVariable.allMatches(t)) {
        final v = m.group(1)!;
        if (!isKnownMapperVariable(v)) {
          errors.add('$at: unknown variable {{$v}}.');
        } else {
          variables.add(v);
        }
      }
    }
    if (variables.contains('child') && children == MapperChildren.none) {
      errors.add(
        '$at: {{child}} is used but "children" is "none"; set it to "child".',
      );
    }
    if (variables.contains('children') && children == MapperChildren.none) {
      errors.add(
        '$at: {{children}} is used but "children" is "none"; set it to "children".',
      );
    }

    if (errors.length > before) return null;
    return ComponentDef(
      selectorText: selectorText as String,
      selectors: selectors,
      widget: (widget as String).trim(),
      positional: positional,
      args: args,
      children: children,
      box: box,
      variables: variables,
      description: (raw['description'] as Object?)?.toString(),
    );
  }
}
