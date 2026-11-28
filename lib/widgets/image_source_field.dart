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
    this.compact = false,
  });

  final String label;
  final ValueChanged<FileUpload?> onChanged;
  final FileUpload? value;
  final String? existingUrl;
  final String helper;
  final double aspectRatio;
  final bool required;
  final bool compact;

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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.modal),
        ),
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
    if (widget.compact) return _buildCompact(context);
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

  Widget _buildCompact(BuildContext context) {
    final upload = widget.value;
    final hasImage = upload != null || (widget.existingUrl ?? '').isNotEmpty;
    final borderColor = _error == null ? AppColors.border : AppColors.error;

    if (!hasImage) {
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
          Container(
            height: 84,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.forestSurface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppColors.forest,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _error ?? widget.helper,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _error == null
                              ? AppColors.textSecondary
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton.tonal(
                  onPressed: _picking ? null : _chooseSource,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forestSurface,
                    foregroundColor: AppColors.forest,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  child: _picking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Pilih'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Filled state
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
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: borderColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 150,
                child: GestureDetector(
                  onTap: () {
                    if (upload != null) {
                      showImagePreview(
                        context,
                        MemoryImage(upload.bytes),
                      );
                    } else if ((widget.existingUrl ?? '').isNotEmpty) {
                      showImagePreview(
                        context,
                        NetworkImage(widget.existingUrl!),
                      );
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      upload != null
                          ? Image.memory(
                              upload.bytes,
                              fit: BoxFit.contain,
                            )
                          : (widget.existingUrl ?? '').isNotEmpty
                          ? Image.network(
                              widget.existingUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => _placeholder(),
                            )
                          : _placeholder(),
                      if (upload != null ||
                          (widget.existingUrl ?? '').isNotEmpty)
                        Positioned(
                          right: AppSpacing.xs,
                          bottom: AppSpacing.xs,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs + 2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.nearBlack.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.zoom_in_rounded,
                                  size: 12,
                                  color: AppColors.white,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'Ketuk untuk perbesar',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        upload?.filename ?? 'Gambar terpilih',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    TextButton.icon(
                      onPressed: _picking ? null : _chooseSource,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Ganti'),
                    ),
                    if (upload != null)
                      IconButton(
                        tooltip: 'Hapus',
                        onPressed: () => widget.onChanged(null),
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
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
            color: AppColors.textSecondary,
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


/// Pratinjau gambar layar penuh dengan pinch-to-zoom.
void showImagePreview(BuildContext context, ImageProvider imageProvider) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Center(
                child: Image(image: imageProvider, fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(dialogContext).padding.top + AppSpacing.sm,
            right: AppSpacing.screen,
            child: Material(
              color: AppColors.surface.withValues(alpha: 0.9),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Tutup',
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
