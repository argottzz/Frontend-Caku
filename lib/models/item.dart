import 'json_utils.dart';

class Item {
  const Item({
    required this.id,
    required this.idKategori,
    required this.namaKategori,
    required this.nama,
    required this.deskripsi,
    required this.imageUrl,
    required this.stok,
    required this.hargaSewaHarian,
    required this.dendaHarian,
    this.originalPrice,
  });

  final int id;
  final int idKategori;
  final String namaKategori;
  final String nama;
  final String deskripsi;
  final String imageUrl;
  final int stok;
  final double hargaSewaHarian;
  final double dendaHarian;
  final double? originalPrice;

  bool get tersedia => stok > 0;
  bool get hasOriginalPrice => originalPrice != null;

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: Json.asInt(json['id_items'] ?? json['id']),
      idKategori: Json.asInt(json['id_kategori']),
      namaKategori: Json.asString(json['nama_kategori']),
      nama: Json.asString(json['nama_item'] ?? json['nama']),
      deskripsi: Json.asString(json['deskripsi']),
      imageUrl: Json.asString(json['image_url'] ?? json['image']).trim(),
      stok: Json.asInt(json['stok']),
      hargaSewaHarian:
          double.tryParse(Json.asString(json['harga_sewa_harian'], '0')) ?? 0,
      dendaHarian:
          double.tryParse(Json.asString(json['denda_harian'], '0')) ?? 0,
      originalPrice: double.tryParse(Json.asString(json['original_price'], '')),
    );
  }
}
