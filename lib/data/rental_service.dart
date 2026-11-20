import 'dart:convert';

import '../core/network/api_client.dart';
import '../models/json_utils.dart';
import '../models/rental.dart';

class RentalPage {
  const RentalPage({required this.rentals, required this.pagination});

  final List<Rental> rentals;
  final Pagination? pagination;
}

class ReturnResult {
  const ReturnResult({
    required this.rental,
    required this.perluPenyesuaianStok,
  });

  final Rental rental;
  final bool perluPenyesuaianStok;
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
    required FileUpload buktiTransfer,
  }) async {
    final fields = {
      'tanggal_mulai': _ymd(tanggalMulai),
      'tanggal_selesai': _ymd(tanggalSelesai),
      'items': jsonEncode(
        items
            .map((line) => {'id_items': line.idItem, 'jumlah': line.jumlah})
            .toList(growable: false),
      ),
    };
    final response = await _client.postMultipart(
      '/rentals',
      fields: fields,
      files: {'bukti_transfer': buktiTransfer},
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

  Future<ReturnResult> processReturn({
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
    return ReturnResult(
      rental: Rental.fromJson(response.dataMap),
      perluPenyesuaianStok: Json.asBool(
        response.dataMap['perlu_penyesuaian_stok'],
      ),
    );
  }

  static String _ymd(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
