import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_theme.dart';
import '../cubit/converter_cubit.dart';
import '../cubit/converter_state.dart';
import '../models/conversion_result.dart';
import 'device_viewport.dart';
import 'interactive_controls.dart';
import 'panel_frame.dart';
import 'ui_renderer.dart';

/// Receives errors raised while the preview builds, lays out or paints
/// (for example RenderFlex overflows), so they can be shown in the panel.
abstract final class PreviewErrors {
  static void Function(String message)? sink;

  static void report(FlutterErrorDetails details) {
    final target = sink;
    if (target == null) return;
    final first = details.exceptionAsString().split('\n').first.trim();
    SchedulerBinding.instance.addPostFrameCallback((_) => target(first));
  }
}

/// Real Flutter widgets rendered from the converted intermediate tree.
class FlutterPreviewPanel extends StatefulWidget {
  const FlutterPreviewPanel({super.key});

  @override
  State<FlutterPreviewPanel> createState() => _FlutterPreviewPanelState();
}

class _FlutterPreviewPanelState extends State<FlutterPreviewPanel> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ConverterCubit>();
    PreviewErrors.sink = (m) {
      if (mounted) cubit.reportPreviewIssue(m);
    };
  }

  @override
  void dispose() {
    PreviewErrors.sink = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConverterCubit>();
    return BlocListener<ConverterCubit, ConverterState>(
      listenWhen: (a, b) => a.result != b.result,
      listener: (_, _) => EfRadio.reset(),
      child: BlocBuilder<ConverterCubit, ConverterState>(
        buildWhen: (a, b) =>
            a.status != b.status ||
            a.result != b.result ||
            a.error != b.error ||
            a.previewSize != b.previewSize ||
            a.previewIssues != b.previewIssues ||
            a.isOutdated != b.isOutdated ||
            a.hasInput != b.hasInput,
        builder: (context, state) {
          final result = state.result;
          return PanelFrame(
            title: 'Flutter Preview',
            icon: Icons.flutter_dash_rounded,
            actions: [
              ...deviceActions(state.previewSize, cubit.setPreviewSize),
              Container(
                width: 1,
                height: 16,
                color: EF.border,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              IconAction(
                icon: Icons.sync_rounded,
                tooltip: 'Reconvert',
                onPressed: state.hasInput && !state.isConverting
                    ? cubit.convertToFlutter
                    : null,
              ),
            ],
            footer: _footer(state),
            child: Column(
              children: [
                if (state.isOutdated) const OutdatedBanner(),
                Expanded(child: _body(context, state, result)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _footer(ConverterState state) {
    final issues = state.previewIssues;
    return Container(
      constraints: const BoxConstraints(minHeight: 30),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: EF.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              issues.isEmpty
                  ? 'Real Flutter widgets · '
                        '${state.previewSize.width.round()} px'
                  : 'Preview issue: ${issues.first}'
                        '${issues.length > 1 ? '  (+${issues.length - 1} more)' : ''}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                color: issues.isEmpty ? EF.faint : EF.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(
    BuildContext context,
    ConverterState state,
    ConversionResult? result,
  ) {
    if (state.isConverting) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: EF.accent),
        ),
      );
    }
    if (state.status == ConversionStatus.failure && result == null) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        color: EF.error,
        title: 'Conversion failed',
        message: state.error ?? 'Something went wrong while converting.',
      );
    }
    if (result == null) {
      return EmptyState(
        icon: Icons.widgets_outlined,
        title: 'No Flutter preview yet',
        message: state.hasInput
            ? 'Click “Convert to Flutter” to render this page with real Flutter widgets.'
            : 'Add some HTML first, then convert it to see the Flutter result here.',
      );
    }
    return DeviceViewport(
      size: state.previewSize,
      builder: (context, scale, w, h) {
        try {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(size: Size(w, h), textScaler: TextScaler.noScaling),
            child: UiRenderer.page(context, result),
          );
        } catch (e) {
          return Center(
            child: Text(
              'The preview could not be rendered: $e',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
      },
    );
  }
}
