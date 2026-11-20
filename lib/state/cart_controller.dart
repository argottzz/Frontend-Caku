import 'package:flutter/foundation.dart';

import '../models/item.dart';

class CartLine {
  CartLine({required this.item, this.quantity = 1});

  final Item item;
  int quantity;

  double get subtotal => item.hargaSewaHarian * quantity;
}

/// Keranjang sisi klien. Backend tidak menyediakan endpoint keranjang;
/// stok final tetap divalidasi server saat pengajuan rental dibuat.
class CartController extends ChangeNotifier {
  final List<CartLine> _lines = [];

  List<CartLine> get lines => List.unmodifiable(_lines);
  bool get isEmpty => _lines.isEmpty;
  bool get isNotEmpty => _lines.isNotEmpty;

  int get totalQuantity =>
      _lines.fold(0, (total, line) => total + line.quantity);

  double get totalPerDay =>
      _lines.fold(0, (total, line) => total + line.subtotal);

  int quantityFor(int itemId) {
    for (final line in _lines) {
      if (line.item.id == itemId) return line.quantity;
    }
    return 0;
  }

  /// Menambah satu unit. Mengembalikan `false` bila stok tidak mencukupi.
  bool add(Item item) {
    final line = _lineFor(item.id);
    if (line == null) {
      if (item.stok <= 0) return false;
      _lines.add(CartLine(item: item));
      notifyListeners();
      return true;
    }
    return increment(item.id);
  }

  bool increment(int itemId) {
    final line = _lineFor(itemId);
    if (line == null) return false;
    if (line.quantity >= line.item.stok) return false;
    line.quantity += 1;
    notifyListeners();
    return true;
  }

  void decrement(int itemId) {
    final line = _lineFor(itemId);
    if (line == null) return;
    if (line.quantity <= 1) {
      _lines.remove(line);
    } else {
      line.quantity -= 1;
    }
    notifyListeners();
  }

  void remove(int itemId) {
    _lines.removeWhere((line) => line.item.id == itemId);
    notifyListeners();
  }

  void clear() {
    if (_lines.isEmpty) return;
    _lines.clear();
    notifyListeners();
  }

  CartLine? _lineFor(int itemId) {
    for (final line in _lines) {
      if (line.item.id == itemId) return line;
    }
    return null;
  }
}
