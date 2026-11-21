import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/state_views.dart';
import 'auth_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _obscure = true;
  bool _loading = false;
  String? _banner;
  Map<String, String> _fieldErrors = const {};

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
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
      await AuthScope.read(
        context,
      ).login(email: _emailController.text, password: _passwordController.text);
      // RootGate mengganti layar setelah status autentikasi berubah.
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _fieldErrors = error.fieldErrors;
        _banner = error.message;
      });
      _formKey.currentState?.validate();
    } catch (error) {
      if (!mounted) return;
      setState(() => _banner = 'Terjadi kesalahan. Silakan coba lagi.');
      debugPrint('Login error: $error');
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
    final auth = AuthScope.of(context);
    return AuthShell(
      title: 'Masuk ke CAKU',
      subtitle: 'Kelola penyewaan perlengkapan camping dalam satu tempat.',
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Belum punya akun?',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextButton(
            onPressed: _loading
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
            child: const Text('Daftar'),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (auth.sessionExpired) ...[
                const InlineNotice(
                  message:
                      'Sesi Anda berakhir. Silakan masuk kembali untuk melanjutkan.',
                  tone: NoticeTone.warning,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (_banner != null) ...[
                InlineNotice(
                  message: _banner!,
                  tone: NoticeTone.error,
                  icon: Icons.error_outline_rounded,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              FieldLabel(label: 'Email', required: true),
              TextFormField(
                controller: _emailController,
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
              FieldLabel(label: 'Kata sandi', required: true),
              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                enabled: !_loading,
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi',
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
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: _loading ? 'Memproses...' : 'Masuk',
                icon: Icons.login_rounded,
                loading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 15,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Akses admin hanya untuk pengelola CAKU.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
