import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_theme.dart';
import '../cubit/converter_cubit.dart';
import '../cubit/converter_state.dart';
import '../services/web_bridge.dart';
import 'device_viewport.dart';
import 'panel_frame.dart';

/// The original HTML rendered by the browser inside a sandboxed iframe, at a
/// selectable device size.
class HtmlPreviewPanel extends StatelessWidget {
  const HtmlPreviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConverterCubit>();
    return BlocBuilder<ConverterCubit, ConverterState>(
      buildWhen: (a, b) =>
          a.previewHtml != b.previewHtml ||
          a.previewVersion != b.previewVersion ||
          a.htmlPreviewSize != b.htmlPreviewSize,
      builder: (context, state) {
        final empty = state.previewHtml.trim().isEmpty;
        final size = state.htmlPreviewSize;
        return PanelFrame(
          title: 'HTML Preview',
          icon: Icons.language_rounded,
          actions: [
            ...deviceActions(size, cubit.setHtmlPreviewSize),
            Container(
              width: 1,
              height: 16,
              color: EF.border,
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),
            IconAction(
              icon: Icons.refresh_rounded,
              tooltip: 'Refresh preview',
              onPressed: empty ? null : cubit.refreshHtmlPreview,
            ),
          ],
          footer: Container(
            height: 30,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: EF.border)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 12,
                  color: EF.success,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Sandboxed browser render · scripts disabled · '
                    '${size.width.round()} px',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: EF.faint),
                  ),
                ),
              ],
            ),
          ),
          child: empty
              ? const EmptyState(
                  icon: Icons.web_asset_outlined,
                  title: 'Nothing to preview yet',
                  message:
                      'The original page appears here as soon as you paste '
                      'or upload some HTML.',
                )
              : DeviceViewport(
                  size: size,
                  scaleChild: false,
                  builder: (context, scale, w, h) => HtmlFrame(
                    key: ValueKey(state.previewVersion),
                    html: state.previewHtml,
                    viewportWidth: w,
                    viewportHeight: h,
                    scale: scale,
                  ),
                ),
        );
      },
    );
  }
}
