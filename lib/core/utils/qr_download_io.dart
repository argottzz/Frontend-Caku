import 'dart:typed_data';

import 'package:gal/gal.dart';

/// Menyimpan gambar QR ke galeri perangkat (Android/iOS).
Future<void> saveQrImage(Uint8List bytes, String name) {
  return Gal.putImageBytes(bytes, name: name);
}
