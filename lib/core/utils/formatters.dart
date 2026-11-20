/// Pemformat angka, uang, dan tanggal berbahasa Indonesia tanpa dependensi
/// tambahan.
abstract final class Formatters {
  static const List<String> _bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> _bulanPanjang = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String rupiah(num value) {
    final rounded = value.round();
    final negative = rounded < 0;
    final digits = rounded.abs().toString();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) buffer.write('.');
      buffer.write(digits[index]);
    }
    return '${negative ? '-' : ''}Rp $buffer';
  }

  /// Uang dari API berupa string desimal, contoh `"75000.00"`.
  static String rupiahFromApi(Object? value) => rupiah(parseMoney(value));

  static double parseMoney(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  /// Angka polos dengan pemisah ribuan, untuk isian formulir.
  static String thousands(num value) {
    final digits = value.round().abs().toString();
    final buffer = StringBuffer(value < 0 ? '-' : '');
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) buffer.write('.');
      buffer.write(digits[index]);
    }
    return buffer.toString();
  }

  static String date(DateTime value) {
    return '${value.day} ${_bulan[value.month - 1]} ${value.year}';
  }

  static String dateLong(DateTime value) {
    return '${value.day} ${_bulanPanjang[value.month - 1]} ${value.year}';
  }

  static String dateTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${date(local)} • $hour:$minute';
  }

  /// Format yang diterima backend: `YYYY-MM-DD`.
  static String ymd(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  /// Membaca `YYYY-MM-DD` atau ISO timestamp dari API.
  static DateTime? parseDate(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static DateTime dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static int daysBetween(DateTime start, DateTime end) {
    return dateOnly(end).difference(dateOnly(start)).inDays + 1;
  }

  static String relativeDate(DateTime value) {
    final now = dateOnly(DateTime.now());
    final target = dateOnly(value);
    final diff = target.difference(now).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Besok';
    if (diff == -1) return 'Kemarin';
    return date(value);
  }
}
