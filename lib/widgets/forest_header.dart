import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Header bergambar hutan dengan gradien hijau pinus.
///
/// Hanya dipakai di Beranda sebagai header pembuka; halaman lain memakai
/// [CakuAppBar] biasa. Jika foto gagal dimuat, gradien pinus tetap tampil
/// sehingga teks putih tidak pernah kehilangan kontras.
class ForestHeader extends StatelessWidget {
  const ForestHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.actions = const [],
    this.height = 190,
    this.hero = false,
    this.rounded = true,
    this.child,
  });

  final String title;
  final String? subtitle;

  /// Teks kecil di atas judul (mis. sapaan atau label role).
  final String? eyebrow;
  final List<Widget> actions;
  final double height;

  /// Mode hero: judul lebih besar untuk beranda.
  final bool hero;

  /// Sudut bawah membulat agar menyatu dengan konten berikutnya.
  final bool rounded;

  /// Konten tambahan di bawah judul (mis. kolom pencarian).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.vertical(
      bottom: Radius.circular(rounded ? AppRadius.modal : 0),
    );

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'asset/images/branding/forest-header.jpg',
              fit: BoxFit.cover,
              alignment: hero ? Alignment.center : Alignment.topCenter,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stack) =>
                  const ColoredBox(color: AppColors.forest),
            ),
            // Gradien gelap dari bawah agar judul putih selalu terbaca.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.5, 1],
                  colors: [
                    Color(0x9910241F),
                    Color(0x8C10241F),
                    Color(0xE610241F),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.md,
                AppSpacing.screen,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (actions.isNotEmpty) ...[
                    Row(children: actions),
                    const Spacer(),
                  ],
                  if (eyebrow != null) ...[
                    Text(
                      eyebrow!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: AppColors.sageLight,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: hero ? 28 : 24,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppColors.white,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                        color: AppColors.sageLight,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                  ],
                  if (child != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    child!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tombol aksi bulat di atas [ForestHeader]: lingkaran Surface dengan ikon
/// Primary, plus badge jumlah pada pojok kanan atas.
class ForestHeaderAction extends StatelessWidget {
  const ForestHeaderAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: onTap,
            icon: Icon(icon, size: 21),
            tooltip: tooltip,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.forest,
              side: const BorderSide(color: AppColors.border),
              shape: const CircleBorder(),
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.forest,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.surface, width: 1.5),
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
