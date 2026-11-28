import 'json_utils.dart';

enum RentalStatus {
  awaitingPayment,
  pending,
  approved,
  ongoing,
  completed,
  rejected;

  static RentalStatus fromApi(Object? value) {
    return switch ('$value'.toLowerCase()) {
      'awaiting_payment' => RentalStatus.awaitingPayment,
      'approved' => RentalStatus.approved,
      'ongoing' => RentalStatus.ongoing,
      'completed' => RentalStatus.completed,
      'rejected' => RentalStatus.rejected,
      _ => RentalStatus.pending,
    };
  }

  String get apiValue => switch (this) {
    RentalStatus.awaitingPayment => 'awaiting_payment',
    _ => name,
  };

  String get label => switch (this) {
    RentalStatus.awaitingPayment => 'Menunggu Pembayaran',
    RentalStatus.pending => 'Menunggu',
    RentalStatus.approved => 'Disetujui',
    RentalStatus.ongoing => 'Berjalan',
    RentalStatus.completed => 'Selesai',
    RentalStatus.rejected => 'Ditolak',
  };

  String get description => switch (this) {
    RentalStatus.awaitingPayment => 'Menunggu pembayaran QR',
    RentalStatus.pending => 'Menunggu verifikasi admin',
    RentalStatus.approved => 'Siap diambil sesuai jadwal',
    RentalStatus.ongoing => 'Sedang dalam masa sewa',
    RentalStatus.completed => 'Sudah dikembalikan',
    RentalStatus.rejected => 'Pengajuan ditolak admin',
  };
}

class RentalItem {
  const RentalItem({
    required this.idDetail,
    required this.idItem,
    required this.namaItem,
    required this.jumlah,
    required this.hargaPerHari,
    required this.dendaPerHari,
    required this.subtotal,
    this.originalPriceAtRental,
  });

  final int idDetail;
  final int idItem;
  final String namaItem;
  final int jumlah;
  final double hargaPerHari;
  final double dendaPerHari;
  final double subtotal;
  final double? originalPriceAtRental;

  factory RentalItem.fromJson(Map<String, dynamic> json) {
    return RentalItem(
      idDetail: Json.asInt(json['id_detail_penyewaan']),
      idItem: Json.asInt(json['id_items']),
      namaItem: Json.asString(json['nama_item']),
      jumlah: Json.asInt(json['jumlah']),
      hargaPerHari:
          double.tryParse(Json.asString(json['harga_perhari'], '0')) ?? 0,
      dendaPerHari:
          double.tryParse(Json.asString(json['denda_perhari'], '0')) ?? 0,
      subtotal: double.tryParse(Json.asString(json['subtotal'], '0')) ?? 0,
      originalPriceAtRental: double.tryParse(
        Json.asString(json['original_price_at_rental'], ''),
      ),
    );
  }
}

class RentalReplacement {
  const RentalReplacement({
    required this.idReplacement,
    required this.idRental,
    required this.totalAmount,
    required this.status,
    this.recordedBy,
    this.completedBy,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final int idReplacement;
  final int idRental;
  final String totalAmount;
  final String status;
  final int? recordedBy;
  final int? completedBy;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isCompleted => status.toLowerCase() == 'completed';

  factory RentalReplacement.fromJson(Map<String, dynamic> json) {
    return RentalReplacement(
      idReplacement: Json.asInt(json['id_replacement']),
      idRental: Json.asInt(json['id_rental']),
      totalAmount: Json.asString(json['total_amount']),
      status: Json.asString(json['status']),
      recordedBy: Json.asIntOrNull(json['recorded_by']),
      completedBy: Json.asIntOrNull(json['completed_by']),
      completedAt: Json.asDate(json['completed_at']),
      createdAt: Json.asDate(json['created_at']),
      updatedAt: Json.asDate(json['updated_at']),
    );
  }
}

class MissingOriginalPriceItem {
  const MissingOriginalPriceItem({
    required this.idItem,
    required this.namaItem,
    required this.jumlah,
  });

  final int idItem;
  final String namaItem;
  final int jumlah;

  factory MissingOriginalPriceItem.fromJson(Map<String, dynamic> json) {
    return MissingOriginalPriceItem(
      idItem: Json.asInt(json['id_items']),
      namaItem: Json.asString(json['nama_item']),
      jumlah: Json.asInt(json['jumlah']),
    );
  }
}

class ReturnRentalResult extends Rental {
  const ReturnRentalResult({
    required super.id,
    required super.idUser,
    required super.namaUser,
    required super.emailUser,
    required super.tanggalMulai,
    required super.tanggalSelesai,
    required super.tanggalKembaliAktual,
    required super.durasiHari,
    required super.buktiTransferUrl,
    super.identityImageUrl,
    super.metodePembayaran,
    super.qrCodePayload,
    super.paidAt,
    required super.status,
    required super.kondisiPengembalian,
    required super.catatanPengembalian,
    required super.jumlahItem,
    required super.totalSewa,
    required super.hariTerlambat,
    required super.totalDenda,
    required super.totalBayar,
    required super.createdAt,
    required super.items,
    super.penggantian,
    required this.perluPenyesuaianStok,
    required this.penggantianPerluDitinjau,
    required this.itemTanpaHargaAsli,
  });

  final bool perluPenyesuaianStok;
  final bool penggantianPerluDitinjau;
  final List<MissingOriginalPriceItem> itemTanpaHargaAsli;

  factory ReturnRentalResult.fromJson(Map<String, dynamic> json) {
    final rental = Rental.fromJson(json);
    return ReturnRentalResult(
      id: rental.id,
      idUser: rental.idUser,
      namaUser: rental.namaUser,
      emailUser: rental.emailUser,
      tanggalMulai: rental.tanggalMulai,
      tanggalSelesai: rental.tanggalSelesai,
      tanggalKembaliAktual: rental.tanggalKembaliAktual,
      durasiHari: rental.durasiHari,
      buktiTransferUrl: rental.buktiTransferUrl,
      identityImageUrl: rental.identityImageUrl,
      metodePembayaran: rental.metodePembayaran,
      qrCodePayload: rental.qrCodePayload,
      paidAt: rental.paidAt,
      status: rental.status,
      kondisiPengembalian: rental.kondisiPengembalian,
      catatanPengembalian: rental.catatanPengembalian,
      jumlahItem: rental.jumlahItem,
      totalSewa: rental.totalSewa,
      hariTerlambat: rental.hariTerlambat,
      totalDenda: rental.totalDenda,
      totalBayar: rental.totalBayar,
      createdAt: rental.createdAt,
      items: rental.items,
      penggantian: rental.penggantian,
      perluPenyesuaianStok: Json.asBool(json['perlu_penyesuaian_stok']),
      penggantianPerluDitinjau: Json.asBool(json['penggantian_perlu_ditinjau']),
      itemTanpaHargaAsli: Json.asMapList(
        json['item_tanpa_harga_asli'],
      ).map(MissingOriginalPriceItem.fromJson).toList(growable: false),
    );
  }
}

class Rental {
  const Rental({
    required this.id,
    required this.idUser,
    required this.namaUser,
    required this.emailUser,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.tanggalKembaliAktual,
    required this.durasiHari,
    required this.buktiTransferUrl,
    this.identityImageUrl = '',
    this.metodePembayaran = 'transfer',
    this.qrCodePayload,
    this.paidAt,
    required this.status,
    required this.kondisiPengembalian,
    required this.catatanPengembalian,
    required this.jumlahItem,
    required this.totalSewa,
    required this.hariTerlambat,
    required this.totalDenda,
    required this.totalBayar,
    required this.createdAt,
    required this.items,
    this.penggantian,
  });

  final int id;
  final int idUser;
  final String namaUser;
  final String emailUser;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final DateTime? tanggalKembaliAktual;
  final int durasiHari;
  final String buktiTransferUrl;
  final String identityImageUrl;
  final String metodePembayaran;
  final String? qrCodePayload;
  final DateTime? paidAt;
  final RentalStatus status;
  final String? kondisiPengembalian;
  final String? catatanPengembalian;
  final int jumlahItem;
  final double totalSewa;
  final int hariTerlambat;
  final double totalDenda;
  final double totalBayar;
  final DateTime? createdAt;
  final List<RentalItem> items;
  final RentalReplacement? penggantian;

  bool get isLate => hariTerlambat > 0;
  bool get canCancel => status == RentalStatus.pending;

  factory Rental.fromJson(Map<String, dynamic> json) {
    final start = Json.asDate(json['tanggal_mulai']) ?? DateTime.now();
    final end = Json.asDate(json['tanggal_selesai']) ?? start;
    return Rental(
      id: Json.asInt(json['id_rental'] ?? json['id']),
      idUser: Json.asInt(json['id_user']),
      namaUser: Json.asString(json['nama_user']),
      emailUser: Json.asString(json['email_user']),
      tanggalMulai: start,
      tanggalSelesai: end,
      tanggalKembaliAktual: Json.asDate(json['tanggal_kembali_aktual']),
      durasiHari: Json.asInt(json['durasi_hari']),
      buktiTransferUrl: Json.asString(
        json['bukti_transfer_url'] ?? json['bukti_transfer'],
      ).trim(),
      identityImageUrl: Json.asString(
        json['identity_image_url'] ?? json['identity_image'],
      ).trim(),
      metodePembayaran: Json.asString(
         json['metode_pembayaran'],
         'transfer',
       ),
       qrCodePayload: Json.asStringOrNull(json['qr_code_payload']),
       paidAt: Json.asDate(json['paid_at']),
       status: RentalStatus.fromApi(json['status']),
      kondisiPengembalian: Json.asStringOrNull(json['kondisi_pengembalian']),
      catatanPengembalian: Json.asStringOrNull(json['catatan_pengembalian']),
      jumlahItem: Json.asInt(json['jumlah_item']),
      totalSewa: double.tryParse(Json.asString(json['total_sewa'], '0')) ?? 0,
      hariTerlambat: Json.asInt(json['hari_terlambat']),
      totalDenda: double.tryParse(Json.asString(json['total_denda'], '0')) ?? 0,
      totalBayar: double.tryParse(Json.asString(json['total_bayar'], '0')) ?? 0,
      createdAt: Json.asDate(json['created_at']),
      items: Json.asMapList(
        json['items'],
      ).map(RentalItem.fromJson).toList(growable: false),
      penggantian: json['penggantian'] is Map<String, dynamic>
          ? RentalReplacement.fromJson(
              json['penggantian'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
