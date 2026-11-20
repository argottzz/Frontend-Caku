import 'package:caku_app/core/utils/formatters.dart';
import 'package:caku_app/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatters.rupiah', () {
    test('memberi pemisah ribuan dan awalan Rp', () {
      expect(Formatters.rupiah(75000), 'Rp 75.000');
      expect(Formatters.rupiah(1250000), 'Rp 1.250.000');
      expect(Formatters.rupiah(0), 'Rp 0');
    });

    test('membaca nilai uang string dari API', () {
      expect(Formatters.rupiahFromApi('75000.00'), 'Rp 75.000');
      expect(Formatters.rupiahFromApi('316000.00'), 'Rp 316.000');
      expect(Formatters.rupiahFromApi(null), 'Rp 0');
    });
  });

  group('Formatters tanggal', () {
    test('memakai nama bulan Indonesia', () {
      expect(Formatters.date(DateTime(2026, 11, 20)), '20 Nov 2026');
      expect(Formatters.dateLong(DateTime(2026, 1, 5)), '5 Januari 2026');
    });

    test('menulis format yang diterima backend', () {
      expect(Formatters.ymd(DateTime(2026, 2, 9)), '2026-02-09');
    });

    test('durasi sewa inklusif', () {
      expect(
        Formatters.daysBetween(DateTime(2026, 11, 17), DateTime(2026, 11, 19)),
        3,
      );
    });
  });

  group('Validators', () {
    test('menolak email tidak valid', () {
      expect(Validators.email('bukan-email'), isNotNull);
      expect(Validators.email('budi@example.com'), isNull);
    });

    test('membatasi panjang kata sandi', () {
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('rahasia123'), isNull);
    });

    test('menerima stok nol tetapi menolak negatif', () {
      expect(Validators.stock('0'), isNull);
      expect(Validators.stock('-1'), isNotNull);
    });

    test('membaca nominal dengan pemisah ribuan', () {
      expect(Validators.money('75.000'), isNull);
      expect(Validators.parseMoney('75.000'), 75000);
      expect(Validators.parseMoney('75000,50'), 75000.5);
    });
  });
}
