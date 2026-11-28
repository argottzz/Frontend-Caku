import 'dart:convert';

import '../core/network/api_client.dart';
import '../models/rental.dart';

class RentalPage {
  const RentalPage({required this.rentals, required this.pagination});

  final List<Rental> rentals;
  final Pagination? pagination;
}

class RentalService {
  RentalService(this._client);

  final ApiClient _client;

  Future<RentalPage> list({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _client.get(
      '/rentals',
      query: {'status': status, 'page': '$page', 'limit': '$limit'},
    );
    return RentalPage(
      rentals: response.dataList.map(Rental.fromJson).toList(growable: false),
      pagination: response.pagination,
    );
  }

  Future<Rental> detail(int id) async {
    final response = await _client.get('/rentals/$id');
    return Rental.fromJson(response.dataMap);
  }

  Future<Rental> create({
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
    required List<({int idItem, int jumlah})> items,
    FileUpload? buktiTransfer,
    required FileUpload identityImage,
    String metodePembayaran = 'transfer',
  }) async {
    final fields = {
      'tanggal_mulai': _ymd(tanggalMulai),
      'tanggal_selesai': _ymd(tanggalSelesai),
      'items': jsonEncode(
        items
            .map((line) => {'id_items': line.idItem, 'jumlah': line.jumlah})
            .toList(growable: false),
      ),
      'metode_pembayaran': metodePembayaran,
    };
    final files = <String, FileUpload>{'identity_image': identityImage};
    if (buktiTransfer != null) {
      files['bukti_transfer'] = buktiTransfer;
    }
    final response = await _client.postMultipart(
      '/rentals',
      fields: fields,
      files: files,
    );
    return Rental.fromJson(response.dataMap);
  }

  /// Konfirmasi pembayaran QR: kirim payload QR ke backend.
  Future<Rental> payWithQr(String qrCodePayload) async {
    final response = await _client.post(
      '/rentals/pay-qr',
      body: {'qr_code_payload': qrCodePayload},
    );
    return Rental.fromJson(response.dataMap);
  }

  Future<String> cancel(int id) async {
    final response = await _client.delete('/rentals/$id');
    return response.message;
  }

  Future<Rental> updateStatus(int id, RentalStatus status) async {
    final response = await _client.patch(
      '/rentals/$id/status',
      body: {'status': status.apiValue},
    );
    return Rental.fromJson(response.dataMap);
  }

  Future<ReturnRentalResult> processReturn({
    required int id,
    required DateTime tanggalKembaliAktual,
    required String kondisiPengembalian,
    String? catatanPengembalian,
  }) async {
    final response = await _client.post(
      '/rentals/$id/return',
      body: {
        'tanggal_kembali_aktual': _ymd(tanggalKembaliAktual),
        'kondisi_pengembalian': kondisiPengembalian,
        if (catatanPengembalian != null &&
            catatanPengembalian.trim().isNotEmpty)
          'catatan_pengembalian': catatanPengembalian.trim(),
      },
    );
    return ReturnRentalResult.fromJson(response.dataMap);
  }

  Future<RentalReplacement> completeReplacement(int id) async {
    final response = await _client.patch(
      '/rentals/$id/replacement',
      body: {'status': 'Completed'},
    );
    return RentalReplacement.fromJson(response.dataMap);
  }

  static String _ymd(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
