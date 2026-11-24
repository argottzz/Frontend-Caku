import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Logo resmi CAKU. Aset dipakai apa adanya: tidak diwarnai ulang, tidak
/// dipotong, dan tidak diregangkan.
class CakuLogo extends StatelessWidget {
  const CakuLogo({
    super.key,
    this.size = 96,
    this.showFrame = false,
    this.semanticLabel = 'Logo CAKU',
  });

  final double size;
  final bool showFrame;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'asset/caku-logo.jpg',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: semanticLabel,
    );

    if (!showFrame) {
      return SizedBox(width: size, height: size, child: image);
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.06),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.sageLight),
      ),
      child: image,
    );
  }
}

/// Logo kecil untuk AppBar.
class CakuLogoMark extends StatelessWidget {
  const CakuLogoMark({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: CakuLogo(size: size, semanticLabel: 'CAKU'),
    );
  }
}
