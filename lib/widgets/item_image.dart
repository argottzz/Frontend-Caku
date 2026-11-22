import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Gambar produk dari URL Cloudinary, dengan placeholder merek bila kosong
/// atau gagal dimuat. Tidak pernah memakai foto contoh hardcoded.
class ItemImage extends StatelessWidget {
  const ItemImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius = AppRadius.lg,
    this.height,
    this.width,
  });

  final String imageUrl;
  final BoxFit fit;
  final double borderRadius;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: width,
        child: imageUrl.trim().isEmpty
            ? const BrandImagePlaceholder()
            : Image.network(
                imageUrl,
                fit: fit,
                width: width,
                height: height,
                filterQuality: FilterQuality.medium,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const BrandImagePlaceholder(loading: true);
                },
                errorBuilder: (context, error, stack) {
                  return const BrandImagePlaceholder();
                },
              ),
      ),
    );
  }
}

class BrandImagePlaceholder extends StatelessWidget {
  const BrandImagePlaceholder({super.key, this.loading = false});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.disabledSurface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              loading
                  ? Icons.hourglass_empty_rounded
                  : Icons.landscape_outlined,
              color: AppColors.decorativeIcon,
              size: 28,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'CAKU',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
                color: AppColors.decorativeIcon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
