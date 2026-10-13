import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Titled panel with a thin border, used for every workspace area.
class PanelFrame extends StatelessWidget {
  const PanelFrame({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.actions = const [],
    this.badge,
    this.footer,
    this.showHeader = true,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final List<Widget> actions;
  final Widget? badge;
  final Widget? footer;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EF.panel,
        borderRadius: BorderRadius.circular(EF.radius),
        border: Border.all(color: EF.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(EF.radius - 1),
        child: Column(
          children: [
            if (showHeader)
              Container(
                height: 42,
                padding: const EdgeInsets.only(left: 14, right: 6),
                decoration: const BoxDecoration(
                  color: EF.panelHeader,
                  border: Border(bottom: BorderSide(color: EF.border)),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 15, color: EF.accent),
                    const SizedBox(width: 8),
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.9,
                        color: EF.muted,
                      ),
                    ),
                    if (badge case final b?) ...[const SizedBox(width: 8), b],
                    const Spacer(),
                    ...actions,
                  ],
                ),
              ),
            Expanded(child: child),
            ?footer,
          ],
        ),
      ),
    );
  }
}

/// Compact ghost icon button with tooltip.
class IconAction extends StatelessWidget {
  const IconAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: 18,
        highlightShape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(6),
        hoverColor: Colors.white.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(
            icon,
            size: 17,
            color: !enabled
                ? EF.faint.withValues(alpha: 0.5)
                : active
                ? EF.accent
                : EF.muted,
          ),
        ),
      ),
    );
  }
}

/// Text + icon ghost button for toolbars.
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = enabled ? EF.text : EF.faint;
    final button = TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: enabled ? EF.accent : EF.faint),
      label: compact
          ? const SizedBox.shrink()
          : Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: 10,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        iconAlignment: IconAlignment.start,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EF.radiusSmall),
          side: const BorderSide(color: EF.border),
        ),
      ),
    );
    return Tooltip(message: tooltip ?? label, child: button);
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.color = EF.faint,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: EF.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: EF.muted,
                ),
              ),
              if (action != null) ...[const SizedBox(height: 16), action!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Small rounded status pill.
class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
