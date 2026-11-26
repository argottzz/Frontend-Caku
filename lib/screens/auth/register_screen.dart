import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/feedback_dialog.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/state_views.dart';
import 'auth_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscure = true;
  bool _loading = false;
  String? _banner;
  Map<String, String> _fieldErrors = const {};

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _banner = null;
      _fieldErrors = const {};
    });
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await AuthScope.read(context).register(
        nama: _namaController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      // RootGate menutup rute ini setelah sesi aktif.
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _fieldErrors = error.fieldErrors;
        _banner = error.message;
      });
      _formKey.currentState?.validate();
      showFeedbackDialog(
        context,
        title: 'Pendaftaran gagal',
        message: error.message,
        success: false,
        actionLabel: 'Coba lagi',
      );
    } catch (error) {
      if (!mounted) return;
      const message = 'Terjadi kesalahan. Silakan coba lagi.';
      setState(() => _banner = message);
      debugPrint('Register error: $error');
      showFeedbackDialog(
        context,
        title: 'Pendaftaran gagal',
        message: message,
        success: false,
        actionLabel: 'Coba lagi',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _serverError(String field) {
    if (_fieldErrors.isEmpty) return null;
    if (_fieldErrors.containsKey(field)) return _fieldErrors[field];
    for (final entry in _fieldErrors.entries) {
      if (entry.key.endsWith('.$field')) return entry.value;
    }
    return null;
  }

  void _clearFieldError(String field) {
    if (_fieldErrors.isEmpty) return;
    setState(() {
      _fieldErrors = Map.of(_fieldErrors)
        ..removeWhere((key, _) => key == field || key.endsWith('.$field'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Buat akun CAKU',
      subtitle: 'Daftar sebagai penyewa untuk mengajukan sewa alat camping.',
      // Halaman ini dibuka dari Login, jadi pengguna harus bisa kembali
      // dengan tombol yang terlihat, bukan hanya gestur/back sistem.
      onBack: _loading || !Navigator.of(context).canPop()
          ? null
          : () => Navigator.of(context).pop(),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sudah punya akun?',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextButton(
            onPressed: _loading ? null : () => Navigator.of(context).pop(),
            child: const Text('Masuk'),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_banner != null) ...[
                InlineNotice(
                  message: _banner!,
                  tone: NoticeTone.error,
                  icon: Icons.error_outline_rounded,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              const FieldLabel(label: 'Nama lengkap', required: true),
              TextFormField(
                controller: _namaController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                enabled: !_loading,
                decoration: const InputDecoration(
                  hintText: 'Nama sesuai identitas',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                ),
                validator: (value) =>
                    Validators.name(value) ?? _serverError('nama'),
                onChanged: (_) => _clearFieldError('nama'),
                onFieldSubmitted: (_) => _emailFocus.requestFocus(),
              ),
              const SizedBox(height: AppSpacing.lg),
              const FieldLabel(label: 'Email', required: true),
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                enabled: !_loading,
                decoration: const InputDecoration(
                  hintText: 'nama@email.com',
                  prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                ),
                validator: (value) =>
                    Validators.email(value) ?? _serverError('email'),
                onChanged: (_) => _clearFieldError('email'),
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
              ),
              const SizedBox(height: AppSpacing.lg),
              const FieldLabel(label: 'Kata sandi', required: true),
              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                obscureText: _obscure,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                enabled: !_loading,
                decoration: InputDecoration(
                  hintText: 'Buat kata sandi',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    tooltip: _obscure
                        ? 'Tampilkan kata sandi'
                        : 'Sembunyikan kata sandi',
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                  ),
                ),
                validator: (value) =>
                    Validators.password(value) ?? _serverError('password'),
                onChanged: (_) => _clearFieldError('password'),
                onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
              ),
              const SizedBox(height: AppSpacing.lg),
              const FieldLabel(label: 'Ulangi kata sandi', required: true),
              TextFormField(
                controller: _confirmController,
                focusNode: _confirmFocus,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                enabled: !_loading,
                decoration: const InputDecoration(
                  hintText: 'Masukkan ulang kata sandi',
                  prefixIcon: Icon(Icons.lock_reset_rounded, size: 20),
                ),
                validator: (value) =>
                    Validators.confirmPassword(value, _passwordController.text),
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: _loading ? 'Mendaftarkan...' : 'Daftar',
                icon: Icons.person_add_alt_1_rounded,
                loading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Dengan mendaftar, akun Anda dibuat dengan akses penyewa.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
