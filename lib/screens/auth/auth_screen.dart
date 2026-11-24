import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/feedback_dialog.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/state_views.dart';
import 'auth_shell.dart';

/// Layar autentikasi: masuk dan daftar dalam satu halaman.
///
/// Dulu terpisah menjadi dua rute (Masuk dan Daftar) yang isinya hampir
/// sama. Sekarang dipilih lewat tab; kerangka [AuthShell] dan penanganan
/// galat server dipakai bersama oleh kedua form.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialTab = 0});

  /// 0 = Masuk, 1 = Daftar.
  final int initialTab;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late int _tab = widget.initialTab.clamp(0, 1);

  void _selectTab(int index) {
    if (_tab == index) return;
    FocusScope.of(context).unfocus();
    setState(() => _tab = index);
  }

  @override
  Widget build(BuildContext context) {
    final isRegister = _tab == 1;
    return AuthShell(
      title: isRegister ? 'Buat akun CAKU' : 'Masuk ke CAKU',
      subtitle: isRegister
          ? 'Daftar sebagai penyewa untuk mengajukan sewa alat camping.'
          : 'Kelola penyewaan perlengkapan camping dalam satu tempat.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AuthTabs(selected: _tab, onSelect: _selectTab),
          const SizedBox(height: AppSpacing.xl),
          // Kunci per tab agar isian dan fokus tiap form tidak saling
          // terbawa saat pengguna berpindah tab.
          if (isRegister)
            const RegisterForm(key: ValueKey('register-form'))
          else
            const LoginForm(key: ValueKey('login-form')),
        ],
      ),
    );
  }
}

/// Pemilih tab "Masuk" / "Daftar" dengan bahasa visual chip aplikasi.
class _AuthTabs extends StatelessWidget {
  const _AuthTabs({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  static const List<String> _labels = ['Masuk', 'Daftar'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          for (int i = 0; i < _labels.length; i++)
            Expanded(
              child: Semantics(
                selected: selected == i,
                button: true,
                child: Material(
                  color: selected == i ? AppColors.moss : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: InkWell(
                    onTap: () => onSelect(i),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      child: Text(
                        _labels[i],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: selected == i
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Form masuk. RootGate mengganti layar setelah status autentikasi berubah.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
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
      showFeedbackDialog(
        context,
        title: 'Gagal masuk',
        message: error.message,
        success: false,
        actionLabel: 'Coba lagi',
      );
    } catch (error) {
      if (!mounted) return;
      const message = 'Terjadi kesalahan. Silakan coba lagi.';
      setState(() => _banner = message);
      debugPrint('Login error: $error');
      showFeedbackDialog(
        context,
        title: 'Gagal masuk',
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
    final auth = AuthScope.of(context);
    return Form(
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
            const FieldLabel(label: 'Email', required: true),
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
            const FieldLabel(label: 'Kata sandi', required: true),
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
    );
  }
}

/// Form daftar. RootGate menutup layar ini setelah sesi aktif.
class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
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
    return Form(
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
            FieldLabel(
              label: 'Kata sandi',
              required: true,
              hint: '6–72 karakter',
            ),
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
    );
  }
}
