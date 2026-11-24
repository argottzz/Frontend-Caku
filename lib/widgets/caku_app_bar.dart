import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'caku_logo.dart';

/// AppBar konsisten dengan logo resmi CAKU.
class CakuAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CakuAppBar({
    super.key,
    this.title = 'CAKU',
    this.subtitle,
    this.actions,
    this.showBack = false,
    this.bottom,
    this.transparent = false,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBack;

  /// Tombol kiri kustom, dipakai layar yang menampilkan detail di dalam
  /// halaman yang sama (kembali ke daftar, bukan keluar halaman).
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  /// Latar transparan untuk app bar di atas header bergambar.
  final bool transparent;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final foreground = transparent ? AppColors.white : AppColors.textPrimary;
    return AppBar(
      backgroundColor: transparent ? Colors.transparent : AppColors.background,
      foregroundColor: foreground,
      automaticallyImplyLeading: showBack && leading == null,
      leading:
          leading ??
          (showBack
              ? null
              : const Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.xs,
                  ),
                  child: CakuLogoMark(size: 34),
                )),
      leadingWidth: leading != null || !showBack ? 58 : null,
      titleSpacing: showBack ? 0 : AppSpacing.sm,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              color: foreground,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: transparent
                    ? AppColors.sageLight
                    : AppColors.textSecondary,
              ),
            ),
        ],
      ),
      actions: actions,
      bottom: bottom,
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
