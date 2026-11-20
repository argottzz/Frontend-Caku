import 'json_utils.dart';

class Category {
  const Category({required this.id, required this.nama});

  final int id;
  final String nama;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: Json.asInt(json['id_kategori'] ?? json['id']),
      nama: Json.asString(json['nama']),
    );
  }
}
