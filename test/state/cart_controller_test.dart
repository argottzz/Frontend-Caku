import 'package:caku_app/models/item.dart';
import 'package:caku_app/state/cart_controller.dart';
import 'package:flutter_test/flutter_test.dart';

Item item({int id = 1, int stock = 2, double price = 50000}) {
  return Item(
    id: id,
    idKategori: 1,
    namaKategori: 'Tenda dan Shelter',
    nama: 'Tenda Dome 4P',
    deskripsi: 'Tenda kapasitas 4 orang',
    imageUrl: '',
    stok: stock,
    hargaSewaHarian: price,
    dendaHarian: 10000,
  );
}

void main() {
  group('CartController', () {
    test('menambah item dan menghitung total', () {
      final cart = CartController();
      expect(cart.add(item()), isTrue);
      expect(cart.add(item()), isTrue);
      expect(cart.totalQuantity, 2);
      expect(cart.totalPerDay, 100000);
      expect(cart.add(item()), isFalse, reason: 'stok hanya 2');
    });

    test('tidak menambah item dengan stok habis', () {
      final cart = CartController();
      expect(cart.add(item(stock: 0)), isFalse);
      expect(cart.isEmpty, isTrue);
    });

    test('pengurangan pada jumlah satu menghapus baris', () {
      final cart = CartController();
      cart.add(item());
      cart.decrement(1);
      expect(cart.isEmpty, isTrue);
      expect(cart.totalQuantity, 0);
    });

    test('menghapus dan mengosongkan keranjang', () {
      final cart = CartController();
      cart.add(item(id: 1));
      cart.add(item(id: 2));
      expect(cart.lines.length, 2);
      cart.remove(1);
      expect(cart.quantityFor(1), 0);
      cart.clear();
      expect(cart.isEmpty, isTrue);
    });
  });
}
