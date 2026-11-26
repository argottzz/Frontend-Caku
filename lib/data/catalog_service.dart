import '../core/network/api_client.dart';
import '../models/category.dart';
import '../models/item.dart';

class ItemPage {
  const ItemPage({required this.items, required this.pagination});

  final List<Item> items;
  final Pagination? pagination;
}

class CatalogService {
  CatalogService(this._client);

  final ApiClient _client;

  Future<List<Category>> categories() async {
    final response = await _client.get('/categories');
    return response.dataList.map(Category.fromJson).toList(growable: false);
  }

  Future<ItemPage> items({
    String? search,
    int? idKategori,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _client.get(
      '/items',
      query: {
        'search': search?.trim(),
        'id_kategori': idKategori?.toString(),
        'page': '$page',
        'limit': '$limit',
      },
    );
    return ItemPage(
      items: response.dataList.map(Item.fromJson).toList(growable: false),
      pagination: response.pagination,
    );
  }

  Future<Item> item(int id) async {
    final response = await _client.get('/items/$id');
    return Item.fromJson(response.dataMap);
  }

  Future<Item> createItem({
    required int idKategori,
    required String nama,
    required String deskripsi,
    required int stok,
    required String hargaSewaHarian,
    required String dendaHarian,
    String? originalPrice,
    FileUpload? image,
  }) async {
    final fields = <String, String>{
      'id_kategori': '$idKategori',
      'nama_item': nama,
      'deskripsi': deskripsi,
      'stok': '$stok',
      'harga_sewa_harian': hargaSewaHarian,
      'denda_harian': dendaHarian,
    };
    if (originalPrice != null && originalPrice.trim().isNotEmpty) {
      fields['original_price'] = originalPrice.trim();
    }
    final response = await _client.postMultipart(
      '/items',
      fields: fields,
      files: {'image': ?image},
    );
    return Item.fromJson(response.dataMap);
  }

  Future<Item> updateItem({
    required int id,
    required int idKategori,
    required String nama,
    required String deskripsi,
    required int stok,
    required String hargaSewaHarian,
    required String dendaHarian,
    String? originalPrice,
    FileUpload? image,
  }) async {
    final fields = <String, String>{
      'id_kategori': '$idKategori',
      'nama_item': nama,
      'deskripsi': deskripsi,
      'stok': '$stok',
      'harga_sewa_harian': hargaSewaHarian,
      'denda_harian': dendaHarian,
    };
    if (originalPrice != null && originalPrice.trim().isNotEmpty) {
      fields['original_price'] = originalPrice.trim();
    }
    final response = await _client.putMultipart(
      '/items/$id',
      fields: fields,
      files: {'image': ?image},
    );
    return Item.fromJson(response.dataMap);
  }

  Future<String> deleteItem(int id) async {
    final response = await _client.delete('/items/$id');
    return response.message;
  }
}
