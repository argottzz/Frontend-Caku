import 'package:flutter/material.dart';

/// Token warna resmi CAKU (sesuai design.md).
abstract final class AppColors {
  // Identitas merek
  static const Color forest = Color(0xFF2A573F); // Forest Pine (primary)
  static const Color forestDeep = Color(0xFF1E2621); // Deep Pine Charcoal
  static const Color orange = Color(0xFFFF7761); // Coral Ember (accent)
  static const Color cream = Color(0xFFF6F7F5); // Mist Stone

  // Netral
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearBlack = Color(0xFF1E2621);
  static const Color gray = Color(0xFF5A635E); // Muted Slate Pine
  static const Color lightGray = Color(0xFFEAECE9); // Soft Ash

  // Permukaan
  static const Color background = Color(0xFFFFFFFF); // Pure White
  static const Color surface = Color(0xFFF6F7F5); // Mist Stone (card & field)
  static const Color surfaceMuted = Color(0xFFEAECE9); // Soft Ash (read-only)
  static const Color border = Color(0xFFE4E7E3); // Soft Mist Border
  static const Color controlBorder = Color(0xFF727874); // Slate Olive
  static const Color focusBorder = forest;
  static const Color errorBorder = Color(0xFFA32929);

  // Teks
  static const Color textPrimary = Color(0xFF1E2621); // Deep Pine Charcoal
  static const Color textSecondary = Color(0xFF5A635E); // Muted Slate Pine
  static const Color textOnDark = white;
  static const Color textOnOrange = Color(0xFF1F1512); // Dark Espresso
  static const Color accentText = Color(0xFFC94632); // Deep Coral
  static const Color decorativeIcon = Color(0xFF8E9490);

  // Status (wajib disertai ikon + label teks)
  static const Color pendingBg = Color(0xFFFFF0D9);
  static const Color pendingText = Color(0xFF8A4A0B);
  static const Color approvedBg = Color(0xFFE7F2EC);
  static const Color approvedText = Color(0xFF2A573F);
  static const Color ongoingBg = Color(0xFFE5EFF8);
  static const Color ongoingText = Color(0xFF2E5B7A);
  static const Color overdueBg = Color(0xFFFCE8E8);
  static const Color overdueText = Color(0xFFA32929);
  static const Color completedBg = forest;
  static const Color completedText = white;
  static const Color rejectedBg = Color(0xFFFCE8E8);
  static const Color rejectedText = Color(0xFFA32929);

  // Alias lama
  static const Color success = Color(0xFF2A573F);
  static const Color successSurface = Color(0xFFE7F2EC);
  static const Color warning = Color(0xFF8A4A0B);
  static const Color warningSurface = Color(0xFFFFF0D9);
  static const Color error = Color(0xFFA32929);
  static const Color errorSurface = Color(0xFFFCE8E8);
  static const Color info = Color(0xFF2E5B7A);
  static const Color infoSurface = Color(0xFFE5EFF8);

  // Aksen lembut
  static const Color forestSurface = Color(0xFFE7F2EC);
  static const Color orangeSurface = Color(0xFFFFEAE6);

  // Disabled
  static const Color disabledSurface = Color(0xFFEAECE9);
  static const Color disabledText = Color(0xFF5A635E);

  // Elevated (modal)
  static const Color elevated = white;
}