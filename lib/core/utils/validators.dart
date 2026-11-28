/// Validasi isian yang mengikuti aturan backend.
abstract final class Validators {
  static final RegExp _email = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
  static final RegExp _money = RegExp(r'^\d+(\.\d{1,2})?$');

  static String? required(String? value, {String label = 'Kolom ini'}) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi.';
    return null;
  }

  static String? name(String? value) {
    final empty = required(value, label: 'Nama');
    if (empty != null) return empty;
    final length = value!.trim().length;
    if (length < 3) return 'Nama minimal 3 karakter.';
    if (length > 100) return 'Nama maksimal 100 karakter.';
    return null;
  }

  static String? email(String? value) {
    final empty = required(value, label: 'Email');
    if (empty != null) return empty;
    if (!_email.hasMatch(value!.trim())) return 'Format email tidak valid.';
    return null;
  }

  static String? password(String? value) {
    final empty = required(value, label: 'Kata sandi');
    if (empty != null) return empty;
    if (value!.length < 6) return 'Kata sandi minimal 6 karakter.';
    if (value.length > 72) return 'Kata sandi maksimal 72 karakter.';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final empty = required(value, label: 'Konfirmasi kata sandi');
    if (empty != null) return empty;
    if (value != original) return 'Konfirmasi kata sandi tidak sama.';
    return null;
  }

  static String? phone(String? value) {
    final empty = required(value, label: 'Nomor telepon');
    if (empty != null) return empty;
    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value!.trim())) {
      return 'Format nomor telepon tidak valid (8-15 digit).';
    }
    return null;
  }

  static String? stock(String? value) {
    final empty = required(value, label: 'Stok');
    if (empty != null) return empty;
    final parsed = int.tryParse(value!.trim());
    if (parsed == null) return 'Stok harus berupa angka bulat.';
    if (parsed < 0) return 'Stok tidak boleh negatif.';
    return null;
  }

  static String? money(String? value, {String label = 'Nominal'}) {
    final empty = required(value, label: label);
    if (empty != null) return empty;
    final normalized = value!.trim().replaceAll('.', '').replaceAll(',', '.');
    if (!_money.hasMatch(normalized)) {
      return '$label harus angka, maksimal 2 desimal.';
    }
    return null;
  }

  /// Mengubah isian uang pengguna (`75.000` atau `75000,50`) menjadi angka.
  static double parseMoney(String value) {
    final normalized = value.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }
}
