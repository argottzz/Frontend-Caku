/// Menyimpan gambar QR: ke galeri di Android/iOS, jadi unduhan berkas di web.
///
/// `package:gal` hanya untuk mobile dan `package:web` hanya bisa dipakai di
/// web, jadi implementasinya dipilih saat kompilasi lewat conditional export.
library;

export 'qr_download_io.dart'
    if (dart.library.js_interop) 'qr_download_web.dart';
