import 'json_utils.dart';

enum RentalStatus {
  pending,
  approved,
  ongoing,
  completed,
  rejected;

  static RentalStatus fromApi(Object? value) {
    return switch ('$value'.toLowerCase()) {
      'approved' => RentalStatus.approved,
      'ongoing' => RentalStatus.ongoing,
      'completed' => RentalStatus.completed,
      'rejected' => RentalStatus.rejected,
      _ => RentalStatus.pending,
    };
  }

  String get apiValue => name;

  String get label => switch (this) {
    RentalStatus.pending => 'Menunggu',
    RentalStatus.approved => 'Disetujui',
    RentalStatus.ongoing => 'Berjalan',
    RentalStatus.completed => 'Selesai',
    RentalStatus.rejected => 'Ditolak',
  };

  String get description => switch (this) {
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
  });

  final int idDetail;
  final int idItem;
  final String namaItem;
  final int jumlah;
  final double hargaPerHari;
  final double dendaPerHari;
  final double subtotal;

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
    );
  }
}
