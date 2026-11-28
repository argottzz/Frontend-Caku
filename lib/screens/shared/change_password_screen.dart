import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/caku_app_bar.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/layout.dart';
import '../../widgets/state_views.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _banner;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _banner = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final message = await AppScope.read(context).auth.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
        confirmPassword: _confirmController.text,
      );
      if (!mounted) return;
      AppSnack.success(
        context,
        message.isEmpty ? 'Password berhasil diperbarui.' : message,
      );
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _banner = error.message);
      AppSnack.error(context, error.message);
    } catch (error) {
      debugPrint('Ubah password error: $error');
      if (mounted) {
        setState(() => _banner = 'Gagal mengubah kata sandi.');
        AppSnack.error(context, 'Gagal mengubah kata sandi.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CakuAppBar(title: 'Ubah Kata Sandi', showBack: true),
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
                Text(
                  'Pastikan kata sandi baru Anda kuat dan tidak digunakan pada '
                  'akun lain untuk menjaga keamanan.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_banner != null) ...[
                  InlineNotice(
                    message: _banner!,
                    tone: NoticeTone.error,
                    icon: Icons.error_outline_rounded,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const FieldLabel(
                        label: 'Kata sandi saat ini',
                        required: true,
                      ),
                      TextFormField(
                        controller: _currentController,
                        obscureText: _obscureCurrent,
                        enabled: !_loading,
                        decoration: InputDecoration(
                          hintText: 'Masukkan kata sandi saat ini',
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            tooltip: _obscureCurrent
                                ? 'Tampilkan kata sandi'
                                : 'Sembunyikan kata sandi',
                            onPressed: () => setState(
                              () => _obscureCurrent = !_obscureCurrent,
                            ),
                            icon: Icon(
                              _obscureCurrent
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi lama wajib diisi.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const FieldLabel(
                        label: 'Kata sandi baru',
                        required: true,
                      ),
                      TextFormField(
                        controller: _newController,
                        obscureText: _obscureNew,
                        enabled: !_loading,
                        decoration: InputDecoration(
                          hintText: 'Masukkan kata sandi baru',
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            tooltip: _obscureNew
                                ? 'Tampilkan kata sandi'
                                : 'Sembunyikan kata sandi',
                            onPressed: () =>
                                setState(() => _obscureNew = !_obscureNew),
                            icon: Icon(
                              _obscureNew
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi baru wajib diisi.';
                          }
                          if (value.length < 6) {
                            return 'Kata sandi baru minimal 6 karakter.';
                          }
                          if (value.length > 72) {
                            return 'Kata sandi baru maksimal 72 karakter.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Minimal 6, maksimal 72 karakter.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const FieldLabel(
                        label: 'Konfirmasi kata sandi baru',
                        required: true,
                      ),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscureConfirm,
                        enabled: !_loading,
                        decoration: InputDecoration(
                          hintText: 'Ulangi kata sandi baru',
                          prefixIcon: const Icon(
                            Icons.lock_reset_rounded,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            tooltip: _obscureConfirm
                                ? 'Tampilkan kata sandi'
                                : 'Sembunyikan kata sandi',
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi kata sandi wajib diisi.';
                          }
                          if (value != _newController.text) {
                            return 'Konfirmasi kata sandi tidak sama.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: _loading
                            ? 'Menyimpan...'
                            : 'Simpan Kata Sandi Baru',
                        icon: Icons.save_rounded,
                        loading: _loading,
                        onPressed: _loading ? null : _submit,
                      ),
                    ],
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
