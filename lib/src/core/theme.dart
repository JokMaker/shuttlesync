import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Core backgrounds
  static const bg = Color(0xFF080810);
  static const bgSurface = Color(0xFF0F0F1A);
  static const bgCard = Color(0xFF0F0F18);

  // Brand accents
  static const purple = Color(0xFF7B5BFF);
  static const teal = Color(0xFF00C896);

  // Glass surfaces
  static const glassWhite = Color(0x0FFFFFFF); // 6% white
  static const glassBorder = Color(0x1AFFFFFF); // 10% white border
  static const glassBorderStrong = Color(0x33FFFFFF); // 20% white border

  // Text
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0x80FFFFFF); // 50% white
  static const textMuted = Color(0x55FFFFFF); // 33% white
  static const textHint = Color(0x33FFFFFF); // 20% white

  // Status
  static const statusOnTime = Color(0xFF00C896);
  static const statusOnTimeBg = Color(0x2600C896);
  static const statusOnTimeBorder = Color(0x4D00C896);
  static const statusDelayed = Color(0xFFEF9F27);
  static const statusDelayedBg = Color(0x26EF9F27);
  static const statusDelayedBorder = Color(0x4DEF9F27);

  // Gradients
  static const List<Color> brandGradient = [purple, teal];
  static const List<Color> heroBg = [Color(0x407B5BFF), Color(0x2600C896)];
}

class AppGradients {
  static const brand = LinearGradient(
    colors: [AppColors.purple, AppColors.teal],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const brandDiagonal = LinearGradient(
    colors: [AppColors.purple, AppColors.teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const heroBg = LinearGradient(
    colors: [Color(0x407B5BFF), Color(0x2600C896)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const meshTop = RadialGradient(
    center: Alignment(0.6, -0.8),
    radius: 1.2,
    colors: [Color(0x8C7B5BFF), Colors.transparent],
  );

  static const meshBottom = RadialGradient(
    center: Alignment(-0.8, 0.8),
    radius: 1.0,
    colors: [Color(0x5900C896), Colors.transparent],
  );
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.purple,
          secondary: AppColors.teal,
          surface: AppColors.bgSurface,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(Colors.white),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.teal
                : AppColors.glassWhite,
          ),
        ),
      );
}

class AppTextStyles {
  static TextStyle outfitBlack(double size, Color color) => GoogleFonts.outfit(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: -0.5,
      );

  static TextStyle outfitBold(double size, Color color) => GoogleFonts.outfit(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle outfitSemiBold(double size, Color color) => GoogleFonts.outfit(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle outfit(
    double size,
    Color color, {
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.outfit(fontSize: size, fontWeight: weight, color: color);
}

/// Compatibility layer: the app currently references [ShuttleSyncTheme] in
/// multiple screens. Keep it, but map it to your new theme.
class ShuttleSyncTheme {
  static const Color amber = AppColors.statusDelayed;
  static const Color teal = AppColors.statusOnTime;
  static const Color ink = AppColors.textPrimary;
  static const LinearGradient heroGradient = AppGradients.brandDiagonal;

  static ThemeData theme() => AppTheme.theme;
}
