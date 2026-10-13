import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../cubit/converter_state.dart';
import 'panel_frame.dart';

/// Mobile / tablet / desktop toggle buttons for a preview header.
List<Widget> deviceActions(
  PreviewSize current,
  ValueChanged<PreviewSize> onChanged,
) {
  return [
    for (final size in PreviewSize.values)
      IconAction(
        icon: switch (size) {
          PreviewSize.mobile => Icons.smartphone_rounded,
          PreviewSize.tablet => Icons.tablet_mac_rounded,
          PreviewSize.desktop => Icons.desktop_windows_outlined,
        },
        tooltip: '${size.label} (${size.width.round()} px)',
        active: current == size,
        onPressed: () => onChanged(size),
      ),
  ];
}

/// A framed "device" shown at [size]. The device is scaled down to fit the
/// available width. [builder] receives the scale and the virtual viewport
/// size in logical pixels.
///
/// With [scaleChild] the child is laid out at the full viewport size and
/// scaled by a [FittedBox] (Flutter content). Without it the child is laid
/// out at the already-scaled size and must scale itself (the iframe).
class DeviceViewport extends StatelessWidget {
  const DeviceViewport({
    super.key,
    required this.size,
    required this.builder,
    this.scaleChild = true,
  });

  final PreviewSize size;
  final Widget Function(
    BuildContext context,
    double scale,
    double width,
    double height,
  )
  builder;
  final bool scaleChild;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        const pad = 14.0;
        final availW = (box.maxWidth - pad * 2).clamp(80.0, double.infinity);
        final availH = (box.maxHeight - pad * 2).clamp(80.0, double.infinity);
        final scale = (availW / size.width).clamp(0.05, 1.0);
        final viewH = availH / scale;
        final content = builder(context, scale, size.width, viewH);
        return Container(
          color: const Color(0xFF0A0D13),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.all(pad),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: EF.borderStrong),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: SizedBox(
                width: size.width * scale,
                height: availH,
                child: scaleChild
                    ? FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: size.width,
                          height: viewH,
                          child: content,
                        ),
                      )
                    : content,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Thin strip announcing that a preview no longer matches the input.
class OutdatedBanner extends StatelessWidget {
  const OutdatedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      color: EF.warning.withValues(alpha: 0.12),
      child: const Row(
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 14, color: EF.warning),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Input changed since the last conversion. Reconvert to update.',
              style: TextStyle(fontSize: 11.5, color: EF.warning),
            ),
          ),
        ],
      ),
    );
  }
}
