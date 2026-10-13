import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_theme.dart';
import '../cubit/converter_cubit.dart';
import '../cubit/converter_state.dart';
import '../services/samples.dart';
import 'mapper_menu.dart';
import 'panel_frame.dart';

(String, Color, IconData) _statusOf(ConverterState s) {
  switch (s.status) {
    case ConversionStatus.converting:
      return ('Converting…', EF.accent, Icons.autorenew_rounded);
    case ConversionStatus.failure:
      return ('Conversion failed', EF.error, Icons.error_outline_rounded);
    case ConversionStatus.success:
    case ConversionStatus.idle:
      if (s.result != null) {
        return s.isOutdated
            ? ('Preview outdated', EF.warning, Icons.history_toggle_off_rounded)
            : ('Converted', EF.success, Icons.check_circle_outline_rounded);
      }
      return s.hasInput
          ? ('Ready to convert', EF.muted, Icons.bolt_rounded)
          : ('Waiting for HTML', EF.faint, Icons.hourglass_empty_rounded);
  }
}

/// Compact application header: brand, status and global actions.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConverterCubit>();
    return Container(
      height: 58,
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 20),
      decoration: const BoxDecoration(
        color: EF.panel,
        border: Border(bottom: BorderSide(color: EF.border)),
      ),
      child: Row(
        children: [
          const _Logo(),
          const SizedBox(width: 10),
          const Text(
            'ElementFlow',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 12),
            Container(width: 1, height: 18, color: EF.border),
            const SizedBox(width: 12),
            const Text(
              'From HTML to Flutter. Seamlessly.',
              style: TextStyle(fontSize: 12.5, color: EF.muted),
            ),
          ],
          const Spacer(),
          BlocBuilder<ConverterCubit, ConverterState>(
            buildWhen: (a, b) =>
                a.status != b.status ||
                a.isOutdated != b.isOutdated ||
                a.hasInput != b.hasInput,
            builder: (context, state) {
              final (label, color, icon) = _statusOf(state);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!compact) Pill(label: label, color: color, icon: icon),
                  if (!compact) const SizedBox(width: 14),
                  SamplesMenu(compact: compact),
                  const SizedBox(width: 8),
                  MapperMenu(compact: compact),
                  const SizedBox(width: 8),
                  GhostButton(
                    label: 'Clear',
                    icon: Icons.restart_alt_rounded,
                    compact: compact,
                    tooltip: 'Clear input and results',
                    onPressed: state.hasInput || state.result != null
                        ? cubit.clearInput
                        : null,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [EF.accent, EF.accentDeep],
        ),
        boxShadow: [
          BoxShadow(
            color: EF.accentStrong.withValues(alpha: 0.45),
            blurRadius: 12,
          ),
        ],
      ),
      child: const Icon(
        Icons.swap_horiz_rounded,
        size: 19,
        color: Colors.white,
      ),
    );
  }
}

/// Dropdown with the demonstration pages.
class SamplesMenu extends StatelessWidget {
  const SamplesMenu({super.key, this.compact = false, this.label = 'Samples'});

  final bool compact;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConverterCubit>();
    return PopupMenuButton<HtmlSample>(
      tooltip: 'Load a sample page',
      color: EF.panelHeader,
      elevation: 8,
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(minWidth: 300, maxWidth: 340),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: EF.borderStrong),
      ),
      onSelected: cubit.loadSample,
      itemBuilder: (context) => [
        for (var i = 0; i < htmlSamples.length; i++)
          PopupMenuItem<HtmlSample>(
            value: htmlSamples[i],
            height: 52,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: EF.accentStrong.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: EF.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        htmlSamples[i].name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: EF.text,
                        ),
                      ),
                      Text(
                        htmlSamples[i].description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, color: EF.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(EF.radiusSmall),
          border: Border.all(color: EF.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_outlined, size: 16, color: EF.accent),
            if (!compact) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: EF.text,
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
  }
}

/// Row under the header: choose which panes to show, then convert.
class ControlBar extends StatelessWidget {
  const ControlBar({super.key});

  static const _icons = {
    WorkspacePane.htmlCode: Icons.code_rounded,
    WorkspacePane.htmlPreview: Icons.language_rounded,
    WorkspacePane.flutterPreview: Icons.flutter_dash_rounded,
    WorkspacePane.dartCode: Icons.terminal_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConverterCubit>();
    return BlocBuilder<ConverterCubit, ConverterState>(
      buildWhen: (a, b) =>
          a.visiblePanes != b.visiblePanes ||
          a.status != b.status ||
          a.result != b.result ||
          a.isOutdated != b.isOutdated ||
          a.hasInput != b.hasInput ||
          a.error != b.error,
      builder: (context, state) {
        final r = state.result;
        final (label, color, icon) = _statusOf(state);
        final summary = r == null
            ? (state.status == ConversionStatus.failure ? label : '')
            : '${r.elementsProcessed} elements · ${r.warningCount} warning'
                  '${r.warningCount == 1 ? '' : 's'} · ${state.generatedLines} lines';
        return Row(
          children: [
            const Text(
              'VIEW',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
                color: EF.faint,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final pane in WorkspacePane.values) ...[
                      _PaneToggle(
                        label: pane.label,
                        icon: _icons[pane]!,
                        selected: state.visiblePanes.contains(pane),
                        onTap: () => cubit.togglePane(pane),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ),
            if (summary.isNotEmpty) ...[
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, color: EF.muted),
                ),
              ),
              const SizedBox(width: 14),
            ],
            _ConvertButton(
              enabled: state.hasInput && !state.isConverting,
              busy: state.isConverting,
              again: r != null,
              onPressed: cubit.convertToFlutter,
            ),
          ],
        );
      },
    );
  }
}

class _PaneToggle extends StatelessWidget {
  const _PaneToggle({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: selected ? 'Hide $label' : 'Show $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EF.radiusSmall),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? EF.accentStrong.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(EF.radiusSmall),
            border: Border.all(
              color: selected
                  ? EF.accentStrong.withValues(alpha: 0.6)
                  : EF.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: selected ? EF.accent : EF.faint),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: selected ? EF.text : EF.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Convert action with conversion summary (narrow layout).
class ConvertBar extends StatelessWidget {
  const ConvertBar({super.key, required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConverterCubit>();
    return BlocBuilder<ConverterCubit, ConverterState>(
      buildWhen: (a, b) =>
          a.status != b.status ||
          a.result != b.result ||
          a.isOutdated != b.isOutdated ||
          a.hasInput != b.hasInput ||
          a.error != b.error,
      builder: (context, state) {
        final (label, color, icon) = _statusOf(state);
        final r = state.result;
        final summary = r == null
            ? (state.status == ConversionStatus.failure
                  ? (state.error ?? '')
                  : 'Converts HTML and CSS into Flutter widgets, entirely in your browser.')
            : '${r.elementsProcessed} elements · ${r.warningCount} warning'
                  '${r.warningCount == 1 ? '' : 's'} · ${state.generatedLines} lines of Dart';
        final button = _ConvertButton(
          enabled: state.hasInput && !state.isConverting,
          busy: state.isConverting,
          again: r != null,
          onPressed: cubit.convertToFlutter,
        );
        final info = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                compact ? label : summary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  color: state.status == ConversionStatus.failure
                      ? EF.error
                      : EF.muted,
                ),
              ),
            ),
          ],
        );
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 4,
            vertical: 10,
          ),
          child: compact
              ? Row(
                  children: [
                    Expanded(child: info),
                    const SizedBox(width: 12),
                    button,
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: info),
                    const SizedBox(width: 16),
                    button,
                    const Spacer(),
                  ],
                ),
        );
      },
    );
  }
}

class _ConvertButton extends StatefulWidget {
  const _ConvertButton({
    required this.enabled,
    required this.busy,
    required this.again,
    required this.onPressed,
  });

  final bool enabled, busy, again;
  final VoidCallback onPressed;

  @override
  State<_ConvertButton> createState() => _ConvertButtonState();
}

class _ConvertButtonState extends State<_ConvertButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    final label = widget.busy
        ? 'Converting…'
        : widget.again
        ? 'Reconvert to Flutter'
        : 'Convert to Flutter';
    return Tooltip(
      message: enabled || widget.busy
          ? 'Convert the HTML to Flutter widgets'
          : 'Add some HTML first',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: enabled ? widget.onPressed : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 26),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: enabled
                    ? (_hover
                          ? const [Color(0xFF8E94FF), EF.accentStrong]
                          : const [EF.accent, EF.accentDeep])
                    : const [Color(0xFF232A38), Color(0xFF1B2230)],
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: EF.accentStrong.withValues(
                          alpha: _hover ? 0.55 : 0.35,
                        ),
                        blurRadius: _hover ? 22 : 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.busy)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(
                    Icons.bolt_rounded,
                    size: 19,
                    color: enabled ? Colors.white : EF.faint,
                  ),
                const SizedBox(width: 9),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: enabled || widget.busy ? Colors.white : EF.faint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tab strip used by the narrow layout.
class WorkspaceTabs extends StatelessWidget {
  const WorkspaceTabs({
    super.key,
    required this.labels,
    required this.icons,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final List<IconData> icons;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: EF.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: EF.border),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(7),
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index
                        ? EF.accentStrong.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icons[i],
                        size: 14,
                        color: i == index ? EF.accent : EF.faint,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          labels[i],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: i == index ? EF.text : EF.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
