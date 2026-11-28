import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Mengunduh gambar QR sebagai berkas lewat browser (Flutter Web).
///
/// `package:gal` tidak punya implementasi untuk web (error
/// MissingPluginException), jadi gambar dibuat sebagai Blob lalu diunduh
/// lewat elemen `<a download>` yang diklik otomatis.
Future<void> saveQrImage(Uint8List bytes, String name) async {
  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'image/png'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = '$name.png';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  // Blob URL dibebaskan setelah jeda: sebagian browser membatalkan unduhan bila
  // URL-nya dicabut tepat setelah klik.
  await Future<void>.delayed(const Duration(seconds: 1));
  web.URL.revokeObjectURL(url);
}
