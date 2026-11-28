import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/admin_application_service.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/caku_app_bar.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/layout.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_badge.dart';
import '../admin/categories_screen.dart';
import 'admin_applications_screen.dart';
import 'change_password_screen.dart';

/// Versi yang ditampilkan di bawah tombol Keluar; mengikuti `pubspec.yaml`.
const String _appVersion = '1.0.0';

/// Profil pengguna. Customer: [14], Admin: [28].
///
/// Satu mode saja: tab Profil pada shell (customer & admin). Admin mendapat
/// section Manajemen & Operasional (permohonan admin, kategori, aturan sewa),
/// sedangkan customer mendapat status permohonan adminnya sendiri.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.loadPendingCount});

  /// Sumber data opsional untuk pengujian; produksi memakai
  /// [AdminApplicationService.pendingCount].
  final Future<int> Function()? loadPendingCount;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Status permohonan admin terakhir (`none`/`pending`/`approved`/`rejected`).
  String? _applicationStatus;

  /// Jumlah permohonan admin yang menunggu ditinjau, untuk lencana menu.
  int _pendingApplications = 0;
  bool _uploadingImage = false;
  bool _removingImage = false;

  Future<void> _changeProfileImage(
    BuildContext context, {
    ImageSource source = ImageSource.gallery,
  }) async {
    final FileUpload? upload;
    try {
      upload = await ImagePickerHelper.pick(source: source);
    } on ImageValidationException catch (error) {
      if (context.mounted) AppSnack.error(context, error.message);
      return;
    } catch (error) {
      debugPrint('Pilih foto profil error: $error');
      if (context.mounted) {
        AppSnack.error(context, 'Gambar tidak dapat dibaca.');
      }
      return;
    }
    if (upload == null || !context.mounted) return;

    setState(() => _uploadingImage = true);
    try {
      final user = await AppScope.read(
        context,
      ).users.updateProfileImage(upload);
      if (!context.mounted) return;
      AuthScope.read(context).setUser(user);
      AppSnack.success(context, 'Foto profil berhasil diperbarui.');
    } on ApiException catch (error) {
      if (context.mounted) AppSnack.error(context, error.message);
    } catch (error) {
      debugPrint('Upload foto profil error: $error');
      if (context.mounted) {
        AppSnack.error(context, 'Gagal mengunggah foto profil.');
      }
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  /// Aksi foto profil dipadatkan ke satu ikon kamera di sudut avatar:
  /// pilih dari galeri, ambil foto, atau hapus foto yang sedang dipakai.
  Future<void> _choosePhotoAction(BuildContext context) async {
    final hasImage =
        (AuthScope.maybeOf(context)?.user?.profileImage ?? '').isNotEmpty;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.pop(sheetContext, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil foto'),
              onTap: () => Navigator.pop(sheetContext, 'camera'),
            ),
            if (hasImage)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Hapus foto',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () => Navigator.pop(sheetContext, 'remove'),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case 'gallery':
        await _changeProfileImage(context);
      case 'camera':
        await _changeProfileImage(context, source: ImageSource.camera);
      case 'remove':
        await _removeProfileImage(context);
    }
  }

  Future<void> _editProfile(BuildContext context) async {
    final user = AuthScope.maybeOf(context)?.user;
    if (user == null) return;
    final namaController = TextEditingController(text: user.nama);
    final phoneController = TextEditingController(text: user.phoneNumber ?? '');
    String? error;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Edit profil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nama lengkap'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor telepon',
                    hintText: '+628123456789',
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    error!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final nama = namaController.text.trim();
                final phone = phoneController.text.trim();
                if (nama.length < 3) {
                  setDialogState(() => error = 'Nama minimal 3 karakter.');
                  return;
                }
                if (phone.isNotEmpty &&
                    !RegExp(r'^\+?[0-9]{8,15}$').hasMatch(phone)) {
                  setDialogState(
                    () => error = 'Format nomor telepon tidak valid.',
                  );
                  return;
                }
                try {
                  final updated = await AppScope.read(context).users
                      .updateProfile(
                        nama: nama,
                        phoneNumber: phone.isEmpty ? null : phone,
                      );
                  if (!mounted) return;
                  AuthScope.read(context).setUser(updated);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, true);
                  }
                } on ApiException catch (e) {
                  setDialogState(() => error = e.message);
                } catch (_) {
                  setDialogState(() => error = 'Gagal memperbarui profil.');
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    namaController.dispose();
    phoneController.dispose();
    if (confirmed == true && mounted) {
      AppSnack.success(context, 'Profil berhasil diperbarui.');
    }
  }

  Future<void> _removeProfileImage(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus foto profil?',
      message: 'Foto profil akan dihapus dan avatar kembali ke inisial.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _removingImage = true);
    try {
      final user = await AppScope.read(context).users.removeProfileImage();
      if (!mounted) return;
      AuthScope.read(context).setUser(user);
      AppSnack.success(context, 'Foto profil berhasil dihapus.');
    } on ApiException catch (error) {
      if (mounted) AppSnack.error(context, error.message);
    } catch (error) {
      debugPrint('Hapus foto profil error: $error');
      if (mounted) AppSnack.error(context, 'Gagal menghapus foto profil.');
    } finally {
      if (mounted) setState(() => _removingImage = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadApplicationStatus();
    _loadPendingApplications();
  }

  /// Lencana "N Baru" pada menu Permohonan Admin.
  ///
  /// Memakai `GET /admin-applications?status=pending&limit=1`; jumlahnya
  /// diambil dari `pagination.total`, bukan panjang daftar.
  Future<void> _loadPendingApplications() async {
    final user = AuthScope.maybeOf(context)?.user;
    if (user == null || !user.isAdmin) return;
    try {
      final loader = widget.loadPendingCount;
      final count = loader != null
          ? await loader()
          : await AppScope.read(context).adminApplications.pendingCount();
      if (!mounted) return;
      setState(() => _pendingApplications = count);
    } catch (error) {
      // Lencana hanya pelengkap: kegagalan memuat tidak memblokir profil.
      debugPrint('Jumlah permohonan admin gagal dimuat: $error');
    }
  }

  /// Hanya keterangan status yang ditampilkan; pengajuan tetap dilakukan di
  /// [AdminApplicationsScreen].
  Future<void> _loadApplicationStatus() async {
    final auth = AuthScope.maybeOf(context);
    final user = auth?.user;
    // Status hanya relevan untuk customer yang sudah punya sesi.
    if (user == null || user.isAdmin) return;
    try {
      final data = await AppScope.read(
        context,
      ).adminApplications.myApplication();
      if (!mounted) return;
      setState(() => _applicationStatus = applicationStatus(data));
    } catch (error) {
      // Status hanya pelengkap: kegagalan memuat tidak boleh memblokir profil.
      debugPrint('Status pengajuan admin gagal dimuat: $error');
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Keluar dari CAKU?',
      message:
          'Anda perlu masuk kembali untuk mengakses katalog dan riwayat sewa.',
      confirmLabel: 'Keluar',
      destructive: true,
    );
    if (confirmed && context.mounted) {
      await AuthScope.read(context).logout();
    }
  }

  Future<void> _showAbout(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tentang CAKU'),
        content: const Text(
          'CAKU - aplikasi penyewaan perlengkapan camping.\n'
          'Versi 1.0.0\n\n'
          'Explore More, Worry Less.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTerms(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Aturan & Ketentuan Sewa'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Penyewa wajib mengembalikan barang sesuai tanggal yang '
                'disepakati.\n'
                '2. Keterlambatan pengembalian dikenakan denda per hari.\n'
                '3. Barang yang rusak atau hilang wajib diganti sesuai '
                'estimasi nilai barang.\n'
                '4. Bukti transfer dan foto jaminan KTP wajib diunggah saat '
                'checkout.\n'
                '5. Penyewa bertanggung jawab atas keamanan barang selama '
                'masa sewa.',
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Teks aturan ini hanya dapat dibaca dari aplikasi. '
                'Perubahan teks belum didukung backend.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final user = auth.user;
    if (user == null) {
      return const Scaffold(
        body: EmptyView(
          title: 'Sesi tidak ditemukan',
          message: 'Silakan masuk kembali untuk melihat profil.',
        ),
      );
    }

    final isAdmin = user.isAdmin;
    final title = isAdmin ? 'Profil Admin' : 'Profil';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CakuAppBar(title: title),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ResponsiveFrame(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.xl,
              AppSpacing.screen,
              AppSpacing.bottomClearance,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _IdentityCard(
                  initials: user.initials,
                  nama: user.nama,
                  email: user.email,
                  roleLabel: user.role.label,
                  showRoleBadge: isAdmin,
                  profileImageUrl: user.profileImage,
                  phoneNumber: user.phoneNumber,
                  uploading: _uploadingImage || _removingImage,
                  onPhotoTap: () => _choosePhotoAction(context),
                  onEdit: () => _editProfile(context),
                ),
                const SizedBox(height: AppSpacing.xl),

                if (!isAdmin) ...[
                  const _SectionLabel('Aktivitas Akun'),
                  const SizedBox(height: AppSpacing.md),
                  _MenuCard(
                    children: [
                      _MenuItem(
                        icon: Icons.assignment_ind_outlined,
                        label: 'Permohonan Menjadi Admin',
                        trailing: _applicationStatus == null
                            ? null
                            : ApplicationStatusBadge(
                                status: _applicationStatus,
                              ),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const AdminApplicationsScreen(),
                            ),
                          );
                          if (mounted) _loadApplicationStatus();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                if (isAdmin) ...[
                  const _SectionLabel('Manajemen & Operasional'),
                  const SizedBox(height: AppSpacing.md),
                  _MenuCard(
                    children: [
                      _MenuItem(
                        icon: Icons.assignment_ind_outlined,
                        label: 'Permohonan Admin',
                        trailing: _pendingApplications > 0
                            ? _CountBadge(count: _pendingApplications)
                            : null,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const AdminApplicationsScreen(),
                            ),
                          );
                          if (mounted) _loadPendingApplications();
                        },
                      ),
                      _MenuItem(
                        icon: Icons.sell_outlined,
                        label: 'Kelola Kategori Barang',
                        onTap: () => _open(context, const CategoriesScreen()),
                      ),
                      _MenuItem(
                        icon: Icons.description_outlined,
                        label: 'Aturan & Ketentuan Sewa',
                        onTap: () => _showTerms(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                const _SectionLabel('Pengaturan Akun'),
                const SizedBox(height: AppSpacing.md),
                _MenuCard(
                  children: [
                    _MenuItem(
                      icon: Icons.lock_outline_rounded,
                      label: 'Ubah Kata Sandi',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      ),
                    ),
                    // Admin sudah mengatur aturan sewa di section di atas,
                    // jadi di sini cukup Tentang CAKU.
                    if (!isAdmin)
                      _MenuItem(
                        icon: Icons.description_outlined,
                        label: 'Syarat & Ketentuan Sewa',
                        onTap: () => _showTerms(context),
                      ),
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      label: 'Tentang CAKU',
                      onTap: () => _showAbout(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                _LogoutCard(onTap: () => _logout(context)),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Text(
                    'Versi Aplikasi $_appVersion',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu identitas pengguna: avatar inisial, nama, email, dan label role.
///
/// Tinggi kartu dijaga ringkas: aksi foto dipadatkan menjadi satu ikon kamera
/// di sudut avatar, jadi tidak ada baris tombol "Ubah/Hapus foto" lagi.
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.initials,
    required this.nama,
    required this.email,
    required this.roleLabel,
    required this.showRoleBadge,
    this.profileImageUrl,
    this.phoneNumber,
    this.uploading = false,
    this.onPhotoTap,
    this.onEdit,
  });

  final String initials;
  final String nama;
  final String email;
  final String roleLabel;
  final bool showRoleBadge;
  final String? profileImageUrl;
  final String? phoneNumber;
  final bool uploading;
  final VoidCallback? onPhotoTap;
  final VoidCallback? onEdit;

  bool get _hasPhone => phoneNumber != null && phoneNumber!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(
            initials: initials,
            imageUrl: profileImageUrl,
            uploading: uploading,
            onTap: uploading ? null : onPhotoTap,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        nama,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    if (showRoleBadge) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _RoleBadge(label: roleLabel),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                if (_hasPhone)
                  Text(
                    _formatPhone(phoneNumber!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  // Teks ini satu-satunya jalan masuk ke dialog edit profil
                  // saat nomor telepon masih kosong.
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '+ Tambahkan nomor telepon',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.moss,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              tooltip: 'Edit profil',
              onPressed: uploading ? null : onEdit,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.edit_outlined, size: 20),
            ),
        ],
      ),
    );
  }
}

/// Avatar bulat dengan ikon kamera kecil di sudut kanan bawah.
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.imageUrl,
    required this.uploading,
    this.onTap,
  });

  static const double _size = 64;

  final String initials;
  final String? imageUrl;
  final bool uploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = (imageUrl ?? '').isNotEmpty;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: _size,
          height: _size,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.forest,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: uploading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : hasImage
              ? Image.network(
                  imageUrl!,
                  width: _size,
                  height: _size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _Initials(initials: initials),
                )
              : _Initials(initials: initials),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.5),
              child: Material(
                color: AppColors.forest,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onTap,
                  customBorder: const CircleBorder(),
                  child: Tooltip(
                    message: hasImage
                        ? 'Ganti foto profil'
                        : 'Tambah foto profil',
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: Icon(
                        Icons.photo_camera_rounded,
                        size: 14,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Text(
      initials,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Lencana jumlah di kanan menu, contoh "2 Baru".
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return BadgePill(
      label: '$count Baru',
      foreground: AppColors.pendingText,
      background: AppColors.pendingBg,
      dense: true,
    );
  }
}

/// Tombol Keluar berbentuk kartu agar tetap utuh di semua ukuran layar.
class _LogoutCard extends StatelessWidget {
  const _LogoutCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.error),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout_rounded, size: 19, color: AppColors.error),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Keluar',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Label heading kecil di atas tiap kelompok kartu.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(
                height: 1,
                color: AppColors.border,
                indent: AppSpacing.card,
                endIndent: AppSpacing.card,
              ),
          ],
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.card,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.forest, size: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: AppSpacing.sm),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Memformat nomor telepon agar mudah dibaca (mis. 0857-3737-2213).
String _formatPhone(String value) {
  final trimmed = value.trim();
  final prefix = trimmed.startsWith('+') ? '+' : '';
  final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  final buffer = StringBuffer(prefix);
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && i % 4 == 0) buffer.write('-');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
