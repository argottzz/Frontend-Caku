import 'package:flutter/material.dart';

/// Token warna resmi CAKU. Seluruh widget wajib memakai token ini,
/// bukan kode hex langsung.
abstract final class AppColors {
  // Identitas merek
  static const Color forest = Color(0xFF214932);
  static const Color forestDeep = Color(0xFF163322);
  static const Color orange = Color(0xFFD48432);
  static const Color cream = Color(0xFFF2E5C7);

  // Netral
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearBlack = Color(0xFF171717);
  static const Color gray = Color(0xFF737373);
  static const Color lightGray = Color(0xFFE5E5E5);

  // Permukaan
  static const Color background = Color(0xFFFAF7F1);
  static const Color surface = white;
  static const Color surfaceMuted = Color(0xFFF4F0E8);
  static const Color border = Color(0xFFE3DCCE);

  // Teks
  static const Color textPrimary = nearBlack;
  static const Color textSecondary = Color(0xFF5C5C5C);
  static const Color textOnDark = white;

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color successSurface = Color(0xFFE8F3E9);
  static const Color warning = Color(0xFFB7791F);
  static const Color warningSurface = Color(0xFFFBF1DF);
  static const Color error = Color(0xFFB3261E);
  static const Color errorSurface = Color(0xFFFBE9E8);
  static const Color info = Color(0xFF2563EB);
  static const Color infoSurface = Color(0xFFE8EFFC);

  // Aksen lembut
  static const Color forestSurface = Color(0xFFE7EDE8);
  static const Color orangeSurface = Color(0xFFFAEBD9);
}
