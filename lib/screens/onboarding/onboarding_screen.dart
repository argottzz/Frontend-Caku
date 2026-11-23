import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../screens/auth/login_screen.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_buttons.dart';

/// Layar onboarding CAKU (3 halaman) sesuai design.md.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0; // ignore: prefer_final_fields

  static const List<_OnboardingPage> _pages = <_OnboardingPage>[
    _OnboardingPage(
      title: 'Sewa Perlengkapan Camping',
      keyword: 'Camping',
      body:
          'Temukan dan sewa perlengkapan camping lengkap untuk petualanganmu.',
      image: 'asset/onboarding-1.jpg',
      fullBleed: true,
    ),
    _OnboardingPage(
      title: 'Pilih Periode & Cek Stok',
      keyword: 'Periode',
      body:
          'Pilih tanggal sewa dan cek ketersediaan stok perlengkapan dengan mudah.',
      image: 'asset/onboarding-2.jpg',
      fullBleed: true,
    ),
    _OnboardingPage(
      title: 'Siap Berpetualang',
      keyword: 'Berpetualang',
      body:
          'Semua kebutuhan outdoor-mu tersedia. Mulai perjalananmu sekarang.',
      image: 'asset/onboarding-3.jpg',
      fullBleed: false,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await AppScope.read(context).storage.writeOnboardingSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_index];
    if (page.fullBleed) {
      return _FullBleedOnboarding(
        page: page,
        index: _index,
        total: _pages.length,
        onSkip: _finish,
        onNext: _next,
      );
    }
    return _BoxedOnboarding(
      page: page,
      index: _index,
      total: _pages.length,
      onFinish: _finish,
      onBack: () => _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ),
    );
  }
}

class _FullBleedOnboarding extends StatelessWidget {
  const _FullBleedOnboarding({
    required this.page,
    required this.index,
    required this.total,
    required this.onSkip,
    required this.onNext,
  });

  final _OnboardingPage page;
  final int index;
  final int total;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height * 0.54,
            child: Image.asset(
              page.image,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.disabledSurface,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.terrain_rounded,
                  color: AppColors.gray,
                  size: 48,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height * 0.54,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.background],
                ),
              ),
            ),
          ),
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.screen,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                ),
                child: const Text('Lewatkan'),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  0,
                  AppSpacing.screen,
                  AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TitleWithKeyword(
                      title: page.title,
                      keyword: page.keyword,
                    ),
                    const SizedBox(height: AppSpacing.sm + 4),
                    Text(
                      page.body,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _Dots(index: index, total: total),
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      label: 'Lanjut',
                      onPressed: onNext,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoxedOnboarding extends StatelessWidget {
  const _BoxedOnboarding({
    required this.page,
    required this.index,
    required this.total,
    required this.onFinish,
    required this.onBack,
  });

  final _OnboardingPage page;
  final int index;
  final int total;
  final VoidCallback onFinish;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Image.asset(
                            page.image,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: AppColors.disabledSurface,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.terrain_rounded,
                                color: AppColors.gray,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _TitleWithKeyword(
                        title: page.title,
                        keyword: page.keyword,
                      ),
                      const SizedBox(height: AppSpacing.sm + 4),
                      Text(
                        page.body,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              _Dots(index: index, total: total),
              const SizedBox(height: AppSpacing.xl),
              AccentButton(
                label: 'Mulai',
                onPressed: onFinish,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleWithKeyword extends StatelessWidget {
  const _TitleWithKeyword({
    required this.title,
    required this.keyword,
  });

  final String title;
  final String keyword;

  @override
  Widget build(BuildContext context) {
    // Warnai kata kunci dan tambahkan garis lengkung aksen tipis.
    final parts = title.split(keyword);
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
            children: [
              TextSpan(text: parts.first),
              TextSpan(
                text: keyword,
                style: const TextStyle(color: AppColors.forest),
              ),
              if (parts.length > 1) TextSpan(text: parts.sublist(1).join(keyword)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.forest,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (dot) {
        final active = dot == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.forest : AppColors.disabledSurface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        );
      }),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.keyword,
    required this.body,
    required this.image,
    required this.fullBleed,
  });

  final String title;
  final String keyword;
  final String body;
  final String image;
  final bool fullBleed;
}

/// Accent pill button (Coral Ember) untuk CTA sorotan.
class AccentButton extends StatelessWidget {
  const AccentButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.textOnOrange,
        disabledBackgroundColor: AppColors.disabledSurface,
        disabledForegroundColor: AppColors.disabledText,
        minimumSize: const Size(44, 50),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppColors.textOnOrange,
              ),
            )
          : Text(label),
    );

    return expand
        ? SizedBox(width: double.infinity, height: 50, child: button)
        : SizedBox(height: 50, child: button);
  }
}