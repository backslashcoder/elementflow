import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ElementFlow palette: deep navy-charcoal workspace with an indigo accent.
abstract final class EF {
  static const bg = Color(0xFF0B0E14);
  static const panel = Color(0xFF11151D);
  static const panelHeader = Color(0xFF151A24);
  static const field = Color(0xFF0D1118);
  static const border = Color(0xFF232A38);
  static const borderStrong = Color(0xFF323B4E);
  static const text = Color(0xFFE6E8EE);
  static const muted = Color(0xFF8B93A5);
  static const faint = Color(0xFF5B6478);
  static const accent = Color(0xFF7C83FF);
  static const accentStrong = Color(0xFF6366F1);
  static const accentDeep = Color(0xFF4F46E5);
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const error = Color(0xFFF87171);

  static const radius = 12.0;
  static const radiusSmall = 8.0;

  static TextStyle code({
    double size = 13,
    Color color = text,
    double? height,
  }) => GoogleFonts.jetBrainsMono(
    fontSize: size,
    color: color,
    height: height ?? 1.55,
    fontFeatures: const [FontFeature.disable('liga')],
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: EF.bg,
    colorScheme: const ColorScheme.dark(
      primary: EF.accentStrong,
      onPrimary: Colors.white,
      secondary: EF.accent,
      surface: EF.panel,
      onSurface: EF.text,
      error: EF.error,
    ),
  );
  final text = GoogleFonts.interTextTheme(base.textTheme)
      .apply(bodyColor: EF.text, displayColor: EF.text);
  return base.copyWith(
    textTheme: text,
    dividerColor: EF.border,
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: const Color(0xFF1B2230),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: EF.borderStrong),
      ),
      textStyle: GoogleFonts.inter(fontSize: 12, color: EF.text),
      waitDuration: const Duration(milliseconds: 350),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(EF.borderStrong),
      radius: const Radius.circular(8),
      thickness: WidgetStateProperty.all(8),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1B2230),
      contentTextStyle: GoogleFonts.inter(fontSize: 13, color: EF.text),
      width: 380,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: EF.borderStrong),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: EF.accent,
      selectionColor: EF.accentStrong.withValues(alpha: 0.4),
    ),
  );
}
