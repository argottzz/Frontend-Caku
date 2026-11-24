import 'package:flutter/material.dart';

/// Token warna resmi CAKU (`desain.md` §2).
///
/// Tiga warna identitas: Primary `#17322E`, Accent `#27524B`, dan Background
/// `#DCEBE6`. Warna pendukung hanya dipakai untuk keterbacaan dan pemisahan
/// permukaan, bukan untuk menggeser identitas.
///
/// Catatan kontras: `textSecondary` di atas `background` hanya ±3.9:1, jadi
/// paragraf panjang wajib ditempatkan di atas `surface`.
abstract final class AppColors {
  // Identitas merek
  static const Color forest = Color(0xFF17322E); // Primary
  static const Color forestDeep = Color(0xFF10241F); // Primary pekat
  static const Color moss = Color(0xFF27524B); // Accent

  /// Nama lama untuk Accent; dipertahankan agar pemakaian lama tidak
  /// kembali ke coral yang sudah dihapus dari desain.
  static const Color orange = moss;
  static const Color cream = Color(0xFFF7FAF8); // bingkai logo

  // Keluarga hijau hutan
  static const Color pine = Color(0xFF10241F); // header & foto
  static const Color sage = Color(0xFFA8C0B6); // garis & ilustrasi
  static const Color sageLight = Color(0xFFC5D7D0); // Border
  static const Color mist = Color(0xFFEAF3EF); // Surface Soft (field)
  static const Color sand = Color(0xFFEAF3EF);
  static const Color bark = Color(0xFF657772);

  // Netral
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearBlack = Color(0xFF172622);
  static const Color gray = Color(0xFF657772); // Text Secondary
  static const Color lightGray = Color(0xFFC5D7D0); // track & garis samar

  // Permukaan
  static const Color background = Color(0xFFDCEBE6); // Background
  static const Color surface = Color(0xFFF7FAF8); // kartu, modal, panel
  static const Color surfaceMuted = Color(0xFFEAF3EF); // read-only
  static const Color border = Color(0xFFC5D7D0);
  static const Color controlBorder = Color(0xFF657772);
  static const Color focusBorder = forest;
  static const Color errorBorder = Color(0xFFB54747);

  // Teks
  static const Color textPrimary = Color(0xFF172622);
  static const Color textSecondary = Color(0xFF657772);
  static const Color textOnDark = white;
  static const Color textOnOrange = white;
  static const Color accentText = Color(0xFF27524B);
  static const Color decorativeIcon = Color(0xFF8A9B95);

  // Status (wajib disertai ikon + label teks)
  static const Color pendingBg = Color(0xFFFBF0DF);
  static const Color pendingText = Color(0xFF8A5717);
  static const Color approvedBg = Color(0xFFE3F0E9);
  static const Color approvedText = Color(0xFF28734E);
  static const Color ongoingBg = Color(0xFFE6EFF3);
  static const Color ongoingText = Color(0xFF356B83);
  static const Color overdueBg = Color(0xFFFBEEEE);
  static const Color overdueText = Color(0xFFB54747);
  static const Color completedBg = Color(0xFF17322E);
  static const Color completedText = white;
  static const Color rejectedBg = Color(0xFFFBEEEE);
  static const Color rejectedText = Color(0xFFB54747);

  // Alias lama
  static const Color success = Color(0xFF28734E);
  static const Color successSurface = Color(0xFFE3F0E9);
  static const Color warning = Color(0xFFA66A24);
  static const Color warningText = Color(0xFF8A5717); // teks di atas warningSurface
  static const Color warningSurface = Color(0xFFFBF0DF);
  static const Color error = Color(0xFFB54747);
  static const Color errorSurface = Color(0xFFFBEEEE);
  static const Color info = Color(0xFF356B83);
  static const Color infoSurface = Color(0xFFE6EFF3);

  // Aksen lembut
  static const Color forestSurface = Color(0xFFE3F0E9);
  static const Color orangeSurface = Color(0xFFEAF3EF);

  // Disabled
  static const Color disabledSurface = Color(0xFFEAF3EF);
  static const Color disabledText = Color(0xFF657772);

  // Elevated (modal)
  static const Color elevated = Color(0xFFF7FAF8);
}
