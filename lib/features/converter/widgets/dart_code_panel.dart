import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_theme.dart';
import '../cubit/converter_cubit.dart';
import '../cubit/converter_state.dart';
import '../models/conversion_result.dart';
import 'code_highlighter.dart';
import 'panel_frame.dart';

enum _Tab { code, report }

/// Generated Dart code plus the conversion report, in one tabbed panel.
class DartCodePanel extends StatefulWidget {
  const DartCodePanel({super.key});

  @override
  State<DartCodePanel> createState() => _DartCodePanelState();
}

class _DartCodePanelState extends State<DartCodePanel> {
  _Tab _tab = _Tab.code;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConverterCubit>();
    return BlocBuilder<ConverterCubit, ConverterState>(
      buildWhen: (a, b) =>
          a.dartSource != b.dartSource ||
          a.result != b.result ||
          a.status != b.status ||
          a.isOutdated != b.isOutdated,
      builder: (context, state) {
        final hasCode = state.dartSource != null;
        final result = state.result;
        return PanelFrame(
          title: 'Dart Code',
          icon: Icons.terminal_rounded,
          actions: [
            IconAction(
              icon: Icons.copy_rounded,
              tooltip: 'Copy Dart code to clipboard',
              onPressed: hasCode ? cubit.copyCode : null,
            ),
            IconAction(
              icon: Icons.download_rounded,
              tooltip: 'Download as generated_page.dart',
              onPressed: hasCode ? cubit.downloadCode : null,
            ),
          ],
          child: Column(
            children: [
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: EF.border)),
                ),
                child: Row(
                  children: [
                    _TabChip(
                      label: 'generated_page.dart',
                      selected: _tab == _Tab.code,
                      onTap: () => setState(() => _tab = _Tab.code),
                    ),
                    const SizedBox(width: 6),
                    _TabChip(
                      label: 'Report',
                      count: result == null
                          ? null
                          : result.warningCount + result.infoCount,
                      countColor: result != null && result.warningCount > 0
                          ? EF.warning
                          : EF.muted,
                      selected: _tab == _Tab.report,
                      onTap: () => setState(() => _tab = _Tab.report),
                    ),
                    const Spacer(),
                    if (state.isOutdated)
                      const Pill(label: 'Outdated', color: EF.warning),
                  ],
                ),
              ),
              Expanded(
                child: _tab == _Tab.code
                    ? (hasCode
                          ? _CodeView(source: state.dartSource!)
                          : EmptyState(
                              icon: Icons.data_object_rounded,
                              title: 'No Dart code yet',
                              message: state.status == ConversionStatus.failure
                                  ? 'Fix the error and convert again.'
                                  : 'Convert your HTML to generate a single, self-contained '
                                        'Dart file you can drop into any Flutter project.',
                            ))
                    : _ReportView(result: result, state: state),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.countColor = EF.muted,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;
  final Color countColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? EF.accentStrong.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? EF.accentStrong.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? EF.text : EF.muted,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: countColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: countColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Highlighted, selectable, scrollable code with a line-number gutter.
class _CodeView extends StatefulWidget {
  const _CodeView({required this.source});

  final String source;

  @override
  State<_CodeView> createState() => _CodeViewState();
}

class _CodeViewState extends State<_CodeView> {
  final _v = ScrollController();
  final _h = ScrollController();

  @override
  void dispose() {
    _v.dispose();
    _h.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = EF.code(size: 12.5);
    final lineCount = '\n'.allMatches(widget.source).length + 1;
    final gutter = List.generate(lineCount, (i) => '${i + 1}').join('\n');
    return Scrollbar(
      controller: _v,
      child: SingleChildScrollView(
        controller: _v,
        child: Scrollbar(
          controller: _h,
          notificationPredicate: (n) => n.depth == 1,
          child: SingleChildScrollView(
            controller: _h,
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    padding: const EdgeInsets.only(right: 14),
                    child: Text(
                      gutter,
                      textAlign: TextAlign.right,
                      style: style.copyWith(color: EF.faint),
                    ),
                  ),
                  SelectableText.rich(
                    TextSpan(children: highlightDart(widget.source, style)),
                    style: style,
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView({required this.result, required this.state});

  final ConversionResult? result;
  final ConverterState state;

  @override
  Widget build(BuildContext context) {
    final r = result;
    if (r == null) {
      return EmptyState(
        icon: Icons.fact_check_outlined,
        color: state.status == ConversionStatus.failure ? EF.error : EF.faint,
        title: state.status == ConversionStatus.failure
            ? 'Conversion failed'
            : 'No report yet',
        message: state.status == ConversionStatus.failure
            ? (state.error ?? 'The conversion did not complete.')
            : 'After converting you will see what was processed and which '
                  'features could only be approximated or were skipped.',
      );
    }
    final unsupported = r.unsupportedFeatures;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Stat(label: 'Elements processed', value: '${r.elementsProcessed}'),
            _Stat(
              label: 'Warnings',
              value: '${r.warningCount}',
              color: r.warningCount > 0 ? EF.warning : EF.success,
            ),
            _Stat(label: 'Notes', value: '${r.infoCount}'),
            _Stat(label: 'Widgets generated', value: '${r.root.size}'),
            _Stat(
              label: 'Code generation',
              value: state.dartSource != null ? 'Completed' : 'Not run',
              color: state.dartSource != null ? EF.success : EF.error,
            ),
            _Stat(label: 'Lines of Dart', value: '${state.generatedLines}'),
            if (r.mapper != null)
              _Stat(
                label: 'Mapped to your widgets',
                value: '${r.mappedCount}',
                color: r.mappedCount > 0 ? EF.accent : EF.warning,
              ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'The code has not been compiled by ElementFlow. Run it in a Flutter '
          'project (Flutter 3.27 or newer) to verify.',
          style: TextStyle(fontSize: 12, color: EF.faint),
        ),
        if (r.mapper != null && r.mappedWidgets.isNotEmpty) ...[
          const SizedBox(height: 18),
          _SectionTitle('Component mapper: ${r.mapper!.name}'),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final e in r.mappedWidgets.entries)
                Pill(label: '${e.key} × ${e.value}', color: EF.accent),
            ],
          ),
        ],
        if (unsupported.isNotEmpty) ...[
          const SizedBox(height: 18),
          const _SectionTitle('Unsupported or approximated features'),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final f in unsupported) Pill(label: f, color: EF.warning),
            ],
          ),
        ],
        const SizedBox(height: 18),
        _SectionTitle('Messages (${r.warnings.length})'),
        if (r.warnings.isEmpty)
          const Text(
            'No warnings. Every element and style was converted.',
            style: TextStyle(fontSize: 13, color: EF.success),
          ),
        for (final w in r.warnings) _WarningTile(w),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
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

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color = EF.text});

  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EF.field,
        borderRadius: BorderRadius.circular(EF.radiusSmall),
        border: Border.all(color: EF.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11.5, color: EF.muted)),
        ],
      ),
    );
  }
}

class _WarningTile extends StatelessWidget {
  const _WarningTile(this.warning);

  final ConversionWarning warning;

  @override
  Widget build(BuildContext context) {
    final isWarn = warning.level == WarningLevel.warning;
    final color = isWarn ? EF.warning : EF.accent;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(EF.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isWarn ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SelectableText(
              warning.message,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: EF.text,
              ),
            ),
          ),
          if (warning.count > 1)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                '×${warning.count}',
                style: const TextStyle(fontSize: 11.5, color: EF.muted),
              ),
            ),
        ],
      ),
    );
  }
}
