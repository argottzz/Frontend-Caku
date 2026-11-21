import 'dart:convert';

import 'package:caku_app/core/network/api_exception.dart';
import 'package:caku_app/models/item.dart';
import 'package:caku_app/models/rental.dart';
import 'package:caku_app/models/report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Item membaca field uang string dan URL gambar', () {
    final json =
        jsonDecode('''
    {
      "id_items": 7,
      "id_kategori": 2,
      "nama_kategori": "Tenda dan Shelter",
      "nama_item": "Tenda Dome 4P",
      "deskripsi": "Tenda kapasitas 4 orang",
      "image": "https://res.cloudinary.com/demo/image/upload/tenda.png",
      "image_url": "https://res.cloudinary.com/demo/image/upload/tenda.png",
      "stok": 4,
      "harga_sewa_harian": "50000.00",
      "denda_harian": "10000.00"
    }
    ''')
            as Map<String, dynamic>;

    final item = Item.fromJson(json);
    expect(item.id, 7);
    expect(item.hargaSewaHarian, 50000);
    expect(item.dendaHarian, 10000);
    expect(item.stok, 4);
    expect(item.imageUrl, contains('cloudinary'));
  });

  test('Rental membaca status, denda, dan detail item', () {
    final json =
        jsonDecode('''
    {
      "id_rental": 3,
      "id_user": 2,
      "nama_user": "Customer Caku",
      "email_user": "customer@caku.test",
      "tanggal_mulai": "2026-11-17",
      "tanggal_selesai": "2026-11-19",
      "tanggal_kembali_aktual": "2026-11-20",
      "durasi_hari": 3,
      "status": "completed",
      "jumlah_item": 1,
      "total_sewa": "360000.00",
      "hari_terlambat": 1,
      "total_denda": "31000.00",
      "total_bayar": "391000.00",
      "items": [
        {
          "id_detail_penyewaan": 1,
          "id_items": 1,
          "nama_item": "Tenda Dome 4P",
          "jumlah": 1,
          "harga_perhari": "50000.00",
          "denda_perhari": "10000.00",
          "subtotal": "150000.00"
        }
      ]
    }
    ''')
            as Map<String, dynamic>;

    final rental = Rental.fromJson(json);
    expect(rental.status, RentalStatus.completed);
    expect(rental.hariTerlambat, 1);
    expect(rental.totalDenda, 31000);
    expect(rental.isLate, isTrue);
    expect(rental.items.single.namaItem, 'Tenda Dome 4P');
  });

  test('ReportSummary membaca ringkasan laporan', () {
    final summary = ReportSummary.fromJson({
      'total_transaksi': 5,
      'transaksi_pending': 1,
      'transaksi_approved': 1,
      'transaksi_ongoing': 1,
      'transaksi_completed': 1,
      'transaksi_rejected': 1,
      'total_sewa': '750000.00',
      'total_denda': '20000.00',
      'total_pendapatan': '770000.00',
    });

    expect(summary.totalTransaksi, 5);
    expect(summary.completed, 1);
    expect(summary.totalPendapatan, 770000);
  });

  test('ApiException memetakan error validasi per field', () {
    final error = ApiException(
      statusCode: 400,
      message: 'Data tidak valid',
      fieldErrors: {'items.0.jumlah': 'Jumlah minimal 1'},
    );
    expect(error.fieldError('jumlah'), 'Jumlah minimal 1');
    expect(error.fieldError('email'), isNull);
  });
}
