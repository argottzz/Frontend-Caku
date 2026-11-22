import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Skala jarak 4pt yang dipakai seluruh layar.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Token khusus sesuai spesifikasi CAKU
  static const double screen = 20; // padding horizontal layar
  static const double section = 20; // jarak antar kelompok utama
  static const double labelGap = 6; // jarak label ke input
  static const double card = 16; // padding dalam card
  static const double listItem = 12; // jarak antar kartu dalam daftar
  static const double grid = 12; // jarak grid
  static const double formField = 16; // jarak antar input
  static const double inline = 8; // jarak ikon ke label
}

/// Radius sudut yang konsisten.
abstract final class AppRadius {
  static const double sm = 8; // status pill / badge
  static const double md = 12; // button & text input
  static const double lg = 16; // card / container utama
  static const double chip = 10; // filter chip
  static const double modal = 20; // modal dialog
  static const double bottomSheet = 20; // bottom sheet (atas)
  static const double pill = 999;
}

abstract final class AppTheme {
  static const String fontFamily = 'PlusJakartaSans';

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.forest,
        primary: AppColors.forest,
        onPrimary: AppColors.white,
        secondary: AppColors.orange,
        onSecondary: AppColors.textOnOrange,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      visualDensity: VisualDensity.standard,
    );

    final textTheme = base.textTheme
        .apply(fontFamily: fontFamily)
        .copyWith(
          // Display / H1
          displayLarge: const TextStyle(
            fontSize: 26,
            height: 1.25,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
            fontFamily: fontFamily,
          ),
          // Heading / H2
          headlineLarge: const TextStyle(
            fontSize: 20,
            height: 1.30,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: AppColors.textPrimary,
            fontFamily: fontFamily,
          ),
          // Title / H3
          titleLarge: const TextStyle(
            fontSize: 16,
            height: 1.35,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: AppColors.textPrimary,
            fontFamily: fontFamily,
          ),
          // Body
          bodyLarge: const TextStyle(
            fontSize: 14,
            height: 1.50,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
            color: AppColors.textPrimary,
            fontFamily: fontFamily,
          ),
          // Body Strong
          bodyMedium: const TextStyle(
            fontSize: 14,
            height: 1.50,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: AppColors.textPrimary,
            fontFamily: fontFamily,
          ),
          // Caption
          bodySmall: const TextStyle(
            fontSize: 12,
            height: 1.40,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
            color: AppColors.textSecondary,
            fontFamily: fontFamily,
          ),
          // Caption Bold / label
          labelLarge: const TextStyle(
            fontSize: 15,
            height: 1.20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: AppColors.textPrimary,
            fontFamily: fontFamily,
          ),
          labelMedium: const TextStyle(
            fontSize: 12,
            height: 1.40,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: AppColors.textPrimary,
            fontFamily: fontFamily,
          ),
          labelSmall: const TextStyle(
            fontSize: 12,
            height: 1.40,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
            color: AppColors.textSecondary,
            fontFamily: fontFamily,
          ),
        );

    // Alias yang dipakai kode lama: headlineMedium, headlineSmall, titleMedium, titleSmall
    final textThemeFull = textTheme.copyWith(
      headlineMedium: textTheme.headlineLarge,
      headlineSmall: textTheme.titleLarge,
      titleMedium: textTheme.titleLarge,
      titleSmall: textTheme.labelMedium,
    );

    return base.copyWith(
      textTheme: textThemeFull,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          fontFamily: fontFamily,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
          fontFamily: fontFamily,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontFamily: fontFamily,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.forest,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.controlBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.controlBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.focusBorder, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.errorBorder, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.errorBorder, width: 1.5),
        ),
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: 12,
          fontFamily: fontFamily,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: AppColors.textOnDark,
          disabledBackgroundColor: AppColors.disabledSurface,
          disabledForegroundColor: AppColors.disabledText,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            fontFamily: fontFamily,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.forest,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            fontFamily: fontFamily,
          ),
          side: const BorderSide(color: AppColors.forest, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.forest,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.forestSurface,
        height: 64,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
            color: states.contains(WidgetState.selected)
                ? AppColors.forest
                : AppColors.textSecondary,
            fontFamily: fontFamily,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? AppColors.forest
                : AppColors.textSecondary,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.forest,
        side: const BorderSide(color: AppColors.controlBorder),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: fontFamily,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.nearBlack,
        contentTextStyle: const TextStyle(
          color: AppColors.white,
          fontFamily: fontFamily,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.modal),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.forest,
        linearTrackColor: AppColors.lightGray,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.forest,
        textColor: AppColors.textPrimary,
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.nearBlack,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontFamily: fontFamily,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

}