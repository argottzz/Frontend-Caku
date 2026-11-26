import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// AppBar konsisten untuk seluruh halaman: judul dan subjudul ditengahkan
/// tanpa ikon pendamping, sedangkan aksi (mis. keranjang) selalu di kanan.
///
/// Dipakai semua layar kecuali Beranda, yang memakai header besar sebagai
/// pembuka aplikasi.
class CakuAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CakuAppBar({
    super.key,
    this.title = 'CAKU',
    this.subtitle,
    this.actions,
    this.showBack = false,
    this.bottom,
    this.leading,
    this.onCartTap,
    this.cartBadge = 0,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBack;

  /// Tombol kiri kustom, dipakai layar yang menampilkan detail di dalam
  /// halaman yang sama (kembali ke daftar, bukan keluar halaman).
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  /// Bila diisi, ikon keranjang tampil sebagai aksi paling kanan dengan posisi
  /// yang sama di semua halaman.
  final VoidCallback? onCartTap;
  final int cartBadge;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading:
          leading ??
          (showBack
              ? IconButton(
                  tooltip: 'Kembali',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                )
              : null),
      titleSpacing: AppSpacing.sm,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
      actions: [
        ...?actions,
        if (onCartTap != null)
          CartButton(quantity: cartBadge, onTap: onCartTap!),
        const SizedBox(width: AppSpacing.sm),
      ],
      bottom: bottom,
    );
  }
}

/// Ikon keranjang di kanan AppBar, dipakai semua halaman agar posisinya
/// konsisten.
class CartButton extends StatelessWidget {
  const CartButton({super.key, required this.quantity, required this.onTap});

  final int quantity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          tooltip: 'Keranjang',
          icon: const Icon(Icons.shopping_cart_outlined, size: 22),
        ),
        if (quantity > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.forest,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.background, width: 1.5),
              ),
              child: Text(
                quantity > 99 ? '99+' : '$quantity',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 9,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Avatar inisial pengguna untuk akses profil.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.initials,
    this.onTap,
    this.radius = 18,
  });

  final String initials;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: 'Profil saya',
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: CircleAvatar(
                radius: radius,
                backgroundColor: AppColors.forest,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: radius * 0.72,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
