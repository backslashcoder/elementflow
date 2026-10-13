import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_theme.dart';
import '../cubit/converter_cubit.dart';
import '../cubit/converter_state.dart';
import '../models/component_mapper.dart';
import '../services/mapper_prompt.dart';
import '../services/mapper_samples.dart';
import 'panel_frame.dart';

enum _MapperAction { upload, guide, remove }

Future<void> pickMapperFile(BuildContext context) async {
  final cubit = context.read<ConverterCubit>();
  try {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null) return;
    cubit.loadMapperFile(file.name, await file.readAsBytes());
  } catch (e) {
    cubit.reportFileError('The mapper file could not be read: $e');
  }
}

/// Header button: choose, upload or remove the component mapper.
class MapperMenu extends StatelessWidget {
  const MapperMenu({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConverterCubit>();
    return BlocBuilder<ConverterCubit, ConverterState>(
      buildWhen: (a, b) => a.mapper != b.mapper,
      builder: (context, state) {
        final active = state.mapper;
        return PopupMenuButton<Object>(
          tooltip: 'Map HTML elements to your own widgets',
          color: EF.panelHeader,
          elevation: 8,
          position: PopupMenuPosition.under,
          constraints: const BoxConstraints(minWidth: 320, maxWidth: 360),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: EF.borderStrong),
          ),
          onSelected: (v) {
            if (v is MapperSample) {
              cubit.loadMapperSample(v);
            } else if (v == _MapperAction.upload) {
              pickMapperFile(context);
            } else if (v == _MapperAction.guide) {
              showMapperDialog(context);
            } else if (v == _MapperAction.remove) {
              cubit.clearMapper();
            }
          },
          itemBuilder: (context) => [
            _item(
              _MapperAction.upload,
              Icons.upload_file_rounded,
              'Upload mapper (.json)',
              'Use your own component library',
            ),
            const PopupMenuDivider(height: 8),
            const PopupMenuItem<Object>(
              enabled: false,
              height: 26,
              child: Text(
                'SAMPLE MAPPERS',
                style: TextStyle(
                  fontSize: 10.5,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                  color: EF.faint,
                ),
              ),
            ),
            for (final s in mapperSamples)
              _item(
                s,
                Icons.widgets_outlined,
                s.name,
                s.description,
                selected: active?.name == s.name,
              ),
            const PopupMenuDivider(height: 8),
            _item(
              _MapperAction.guide,
              Icons.menu_book_outlined,
              active == null
                  ? 'How mappers work'
                  : 'View active mapper & format',
              'Format reference and template',
            ),
            if (active != null)
              _item(
                _MapperAction.remove,
                Icons.link_off_rounded,
                'Remove mapper',
                'Back to standard Flutter widgets',
              ),
          ],
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(EF.radiusSmall),
              color: active != null
                  ? EF.accentStrong.withValues(alpha: 0.16)
                  : null,
              border: Border.all(
                color: active != null
                    ? EF.accentStrong.withValues(alpha: 0.6)
                    : EF.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.extension_outlined,
                  size: 16,
                  color: active != null ? EF.accent : EF.muted,
                ),
                if (!compact) ...[
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      active == null ? 'Mapper' : active.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: EF.text,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 18,
                  color: EF.muted,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PopupMenuItem<Object> _item(
    Object value,
    IconData icon,
    String title,
    String subtitle, {
    bool selected = false,
  }) {
    return PopupMenuItem<Object>(
      value: value,
      height: 52,
      child: Row(
        children: [
          Icon(icon, size: 18, color: selected ? EF.accent : EF.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: EF.text,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: EF.muted),
                ),
              ],
            ),
          ),
          if (selected)
            const Icon(Icons.check_rounded, size: 16, color: EF.accent),
        ],
      ),
    );
  }
}

Future<void> showMapperDialog(BuildContext context) {
  final cubit = context.read<ConverterCubit>();
  return showDialog<void>(
    context: context,
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _MapperDialog()),
  );
}

class _MapperDialog extends StatelessWidget {
  const _MapperDialog();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConverterCubit>();
    return Dialog(
      backgroundColor: EF.panel,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(EF.radius),
        side: const BorderSide(color: EF.borderStrong),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 720),
        child: BlocBuilder<ConverterCubit, ConverterState>(
          buildWhen: (a, b) =>
              a.mapper != b.mapper || a.mapperErrors != b.mapperErrors,
          builder: (context, state) {
            final m = state.mapper;
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 10, 14),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: EF.border)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.extension_outlined,
                        size: 18,
                        color: EF.accent,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Component mapper',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconAction(
                        icon: Icons.close_rounded,
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text(
                        'Teams rarely use stock Flutter widgets. A mapper tells ElementFlow '
                        'which of your own widgets replace which HTML elements, so the '
                        'generated Dart code uses your component library and theme. '
                        'Elements are matched with CSS selectors; the most specific match wins.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.55,
                          color: EF.muted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const _Note(
                        'The Flutter preview inside ElementFlow cannot load your widgets, so it '
                        'shows the standard Flutter equivalent. The generated Dart code and the '
                        'conversion report show where your widgets are used.',
                      ),
                      if (state.mapperErrors.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _Errors(state.mapperErrors),
                      ],
                      const SizedBox(height: 18),
                      if (m != null) _Active(mapper: m) else const _NoMapper(),
                      const SizedBox(height: 22),
                      const _Heading('Generate a mapper with AI'),
                      const _AiPrompt(),
                      const SizedBox(height: 22),
                      const _Heading('File format'),
                      _CodeBox(mapperTemplate),
                      const SizedBox(height: 8),
                      const Text(
                        'Optional top-level keys: "description", "imports" (package/dart libraries '
                        'added to the generated file), "theme" (Dart expression for '
                        'MaterialApp.theme) and "declarations" (Dart source for helper widgets, '
                        'appended to the file). Per component: "selector", "widget" (class or '
                        'named constructor), "positional" and "args" (Dart expression templates), '
                        '"children" (none | child | children) and "box" (none | margin | size | all; '
                        'which CSS box parts still wrap your widget, default margin).',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.55,
                          color: EF.muted,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _Heading('Template variables'),
                      for (final (name, desc) in mapperVariableDocs)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: SelectableText(
                                  name,
                                  style: EF.code(size: 12, color: EF.warning),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  desc,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    height: 1.45,
                                    color: EF.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: EF.border)),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      GhostButton(
                        label: 'Upload mapper',
                        icon: Icons.upload_file_rounded,
                        onPressed: () => pickMapperFile(context),
                      ),
                      GhostButton(
                        label: 'Copy AI prompt',
                        icon: Icons.auto_awesome_outlined,
                        onPressed: cubit.copyMapperPrompt,
                        tooltip: 'Copy a prompt that makes an AI assistant write a mapper for your component library',
                      ),
                      GhostButton(
                        label: 'Download template',
                        icon: Icons.download_rounded,
                        onPressed: cubit.downloadMapperTemplate,
                      ),
                      if (m != null)
                        GhostButton(
                          label: 'Download active mapper',
                          icon: Icons.save_alt_rounded,
                          onPressed: () => cubit.downloadMapper(m),
                        ),
                      if (m != null)
                        GhostButton(
                          label: 'Remove',
                          icon: Icons.link_off_rounded,
                          onPressed: cubit.clearMapper,
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 0.9,
        fontWeight: FontWeight.w600,
        color: EF.muted,
      ),
    ),
  );
}

class _Note extends StatelessWidget {
  const _Note(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: EF.accent.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(EF.radiusSmall),
      border: Border.all(color: EF.accent.withValues(alpha: 0.3)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline_rounded, size: 16, color: EF.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, height: 1.5, color: EF.text),
          ),
        ),
      ],
    ),
  );
}

class _Errors extends StatelessWidget {
  const _Errors(this.errors);
  final List<String> errors;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: EF.error.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(EF.radiusSmall),
      border: Border.all(color: EF.error.withValues(alpha: 0.35)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The last mapper could not be loaded',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: EF.error,
          ),
        ),
        const SizedBox(height: 6),
        for (final e in errors)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: SelectableText(
              '• $e',
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: EF.text,
              ),
            ),
          ),
      ],
    ),
  );
}

class _NoMapper extends StatelessWidget {
  const _NoMapper();

  @override
  Widget build(BuildContext context) => const Text(
    'No mapper is active: standard Flutter widgets are generated. Pick a sample from '
    'the Mapper menu or upload your own file.',
    style: TextStyle(fontSize: 13, color: EF.faint),
  );
}

class _Active extends StatelessWidget {
  const _Active({required this.mapper});
  final ComponentMapper mapper;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EF.field,
        borderRadius: BorderRadius.circular(EF.radiusSmall),
        border: Border.all(color: EF.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                mapper.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              const Pill(
                label: 'Active',
                color: EF.success,
                icon: Icons.check_rounded,
              ),
            ],
          ),
          if (mapper.description != null) ...[
            const SizedBox(height: 4),
            Text(
              mapper.description!,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: EF.muted,
              ),
            ),
          ],
          if (mapper.imports.isNotEmpty || mapper.theme != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final i in mapper.imports)
                  Pill(label: i, color: EF.accent),
                if (mapper.theme != null)
                  const Pill(label: 'custom theme', color: EF.accent),
              ],
            ),
          ],
          const SizedBox(height: 12),
          for (final c in mapper.components)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: SelectableText(
                      c.selectorText,
                      style: EF.code(size: 12, color: EF.warning),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: EF.faint,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: SelectableText(
                      c.widget,
                      style: EF.code(size: 12, color: Syntaxish.type),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Colors reused from the code highlighter palette.
abstract final class Syntaxish {
  static const type = Color(0xFF82AAFF);
}

class _CodeBox extends StatelessWidget {
  const _CodeBox(this.code);
  final String code;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: EF.field,
      borderRadius: BorderRadius.circular(EF.radiusSmall),
      border: Border.all(color: EF.border),
    ),
    child: SelectableText(code, style: EF.code(size: 12)),
  );
}

/// Explains and offers the prompt that turns a component library into a mapper.
class _AiPrompt extends StatefulWidget {
  const _AiPrompt();

  @override
  State<_AiPrompt> createState() => _AiPromptState();
}

class _AiPromptState extends State<_AiPrompt> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConverterCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Do not write the mapper by hand. Copy this prompt, give it to an AI assistant '
          'that can read your component library (Claude Code, Cursor, ChatGPT with your '
          'files...), then save the JSON it returns and upload it here. The prompt contains '
          'the full file format, every template variable and a self-check, so the result '
          'is validated by ElementFlow on upload.',
          style: TextStyle(fontSize: 12.5, height: 1.55, color: EF.muted),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            GhostButton(
              label: 'Copy prompt',
              icon: Icons.copy_rounded,
              onPressed: cubit.copyMapperPrompt,
            ),
            GhostButton(
              label: _open ? 'Hide prompt' : 'Show prompt',
              icon: _open
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
              onPressed: () => setState(() => _open = !_open),
            ),
          ],
        ),
        if (_open) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 320),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: EF.field,
              borderRadius: BorderRadius.circular(EF.radiusSmall),
              border: Border.all(color: EF.border),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                buildMapperPrompt(),
                style: EF.code(size: 11.5),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
