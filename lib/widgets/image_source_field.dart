import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/image_picker_helper.dart';
import '../core/network/api_client.dart';

/// Pemilih gambar dengan pratinjau. Dipakai untuk foto barang dan bukti
/// transfer. Validasi ukuran/format dilakukan sebelum unggah.
class ImageSourceField extends StatefulWidget {
  const ImageSourceField({
    super.key,
    required this.label,
    required this.onChanged,
    this.value,
    this.existingUrl,
    this.helper = 'JPG, JPEG, PNG, atau WEBP. Maksimal 5 MB.',
    this.aspectRatio = 16 / 10,
    this.required = false,
  });

  final String label;
  final ValueChanged<FileUpload?> onChanged;
  final FileUpload? value;
  final String? existingUrl;
  final String helper;
  final double aspectRatio;
  final bool required;

  @override
  State<ImageSourceField> createState() => _ImageSourceFieldState();
}

class _ImageSourceFieldState extends State<ImageSourceField> {
  bool _picking = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _picking = true;
      _error = null;
    });
    try {
      final upload = await ImagePickerHelper.pick(source: source);
      if (upload == null) return;
      widget.onChanged(upload);
    } on ImageValidationException catch (error) {
      setState(() => _error = error.message);
    } catch (error) {
      debugPrint('Gagal memilih gambar: $error');
      setState(
        () => _error = 'Gambar tidak dapat dibaca. Coba pilih file lain.',
      );
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _chooseSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil foto'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
    if (source != null) await _pick(source);
  }

  @override
  Widget build(BuildContext context) {
    final upload = widget.value;
    final hasImage = upload != null || (widget.existingUrl ?? '').isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.required)
              const Text(
                ' *',
                style: TextStyle(color: AppColors.error, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: InkWell(
            onTap: _picking ? null : _chooseSource,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: _error == null ? AppColors.border : AppColors.error,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (upload != null)
                    Image.memory(
                      upload.bytes,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    )
                  else if ((widget.existingUrl ?? '').isNotEmpty)
                    Image.network(
                      widget.existingUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder(),
                    )
                  else
                    _placeholder(),
                  Positioned(
                    right: AppSpacing.sm,
                    bottom: AppSpacing.sm,
                    child: Material(
                      color: AppColors.nearBlack.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_picking)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            else
                              const Icon(
                                Icons.upload_rounded,
                                size: 16,
                                color: AppColors.white,
                              ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              hasImage ? 'Ganti foto' : 'Pilih foto',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (upload != null)
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Material(
                        color: AppColors.nearBlack.withValues(alpha: 0.72),
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: 'Hapus gambar',
                          onPressed: () => widget.onChanged(null),
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _error ?? widget.helper,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: _error == null ? AppColors.textSecondary : AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.add_photo_alternate_outlined,
            size: 30,
            color: AppColors.gray,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Belum ada gambar',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
