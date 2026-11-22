import 'package:flutter/material.dart';

/// Token warna resmi CAKU. Seluruh widget wajib memakai token ini,
/// bukan kode hex langsung.
abstract final class AppColors {
  // Identitas merek
  static const Color forest = Color(0xFF214932);
  static const Color forestDeep = Color(0xFF163322);
  static const Color orange = Color(0xFFD48432); // Accent Block / Badge
  static const Color cream = Color(0xFFF2E5C7); // Sand Cream

  // Netral
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearBlack = Color(0xFF171717);
  static const Color gray = Color(0xFF5F635D); // Muted Earth Gray
  static const Color lightGray = Color(0xFFE5E5DF); // Disabled Surface / Hairline

  // Permukaan
  static const Color background = Color(0xFFF2E5C7); // Sand Cream
  static const Color surface = white; // Pure White
  static const Color surfaceMuted = Color(0xFFF5F5F3); // Soft Stone (read-only)
  static const Color border = Color(0xFFE5E5DF); // Divider / Hairline
  static const Color controlBorder = Color(0xFF73766F); // Slate Olive
  static const Color focusBorder = forest; // Forest Green
  static const Color errorBorder = Color(0xFFA32929);

  // Teks
  static const Color textPrimary = Color(0xFF353B36); // Charcoal Forest
  static const Color textSecondary = Color(0xFF5F635D); // Muted Earth Gray
  static const Color textOnDark = white;
  static const Color textOnOrange = Color(0xFF1F1A14); // Dark Espresso
  static const Color accentText = Color(0xFF9E5814); // Deep Ochre (teks oranye di atas putih)
  static const Color decorativeIcon = Color(0xFF8A8A84);

  // Status (wajib disertai ikon + label teks)
  static const Color pendingBg = Color(0xFFFFF0D9);
  static const Color pendingText = Color(0xFF8A4A0B);
  static const Color approvedBg = Color(0xFFE8F1E9);
  static const Color approvedText = Color(0xFF477653);
  static const Color ongoingBg = Color(0xFFE5EFF8);
  static const Color ongoingText = Color(0xFF2E5B7A);
  static const Color overdueBg = Color(0xFFFCE8E8);
  static const Color overdueText = Color(0xFFA32929);
  static const Color completedBg = forest;
  static const Color completedText = white;
  static const Color rejectedBg = Color(0xFFFCE8E8);
  static const Color rejectedText = Color(0xFFA32929);

  // Status lama (alias agar kode lama tetap jalan)
  static const Color success = Color(0xFF2E7D32);
  static const Color successSurface = Color(0xFFE8F3E9);
  static const Color warning = Color(0xFF8A4A0B);
  static const Color warningSurface = Color(0xFFFFF0D9);
  static const Color error = Color(0xFFA32929);
  static const Color errorSurface = Color(0xFFFCE8E8);
  static const Color info = Color(0xFF2E5B7A);
  static const Color infoSurface = Color(0xFFE5EFF8);

  // Aksen lembut
  static const Color forestSurface = Color(0xFFE7EDE8);
  static const Color orangeSurface = Color(0xFFFAEBD9);

  // Disabled
  static const Color disabledSurface = Color(0xFFE5E5DF);
  static const Color disabledText = Color(0xFF5F635D);
}