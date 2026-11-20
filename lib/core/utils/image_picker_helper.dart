import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../network/api_client.dart';

/// Membaca gambar dari galeri/kamera dan menyiapkannya untuk multipart.
class ImagePickerHelper {
  ImagePickerHelper._();

  static const int maxBytes = 5 * 1024 * 1024;
  static const Set<String> allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  static Future<FileUpload?> pick({
    ImageSource source = ImageSource.gallery,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    if (bytes.lengthInBytes > maxBytes) {
      throw const ImageValidationException(
        'Ukuran gambar melebihi 5 MB. Pilih gambar lain.',
      );
    }

    final extension = _extensionOf(picked.name);
    if (!allowedExtensions.contains(extension)) {
      throw const ImageValidationException(
        'Format gambar harus JPG, JPEG, PNG, atau WEBP.',
      );
    }

    debugPrint('Gambar dipilih: ${picked.name} (${bytes.lengthInBytes} byte)');
    return FileUpload(
      filename: picked.name,
      bytes: bytes,
      mimeType: _mimeFor(extension),
    );
  }

  static String _extensionOf(String filename) {
    final dot = filename.lastIndexOf('.');
    if (dot == -1 || dot == filename.length - 1) return '';
    return filename.substring(dot + 1).toLowerCase();
  }

  static String _mimeFor(String extension) {
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }
}

class ImageValidationException implements Exception {
  const ImageValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
