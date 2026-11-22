import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../screens/auth/login_screen.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_buttons.dart';

/// Layar onboarding CAKU (3 halaman).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  // TODO: ganti body dengan copy final dari desainer.
  static const List<_OnboardingPage> _pages = <_OnboardingPage>[
    _OnboardingPage(
      title: 'Discover Your Adventure',
      body:
          'Temukan destinasi camping terbaik dan rencanakan petualanganmu dengan mudah.',
      image: 'asset/onboarding-1.jpg',
    ),
    _OnboardingPage(
      title: 'Gear Up, Without the Hassle',
      body:
          'Sewa perlengkapan camping lengkap tanpa ribet, siap pakai kapan saja.',
      image: 'asset/onboarding-2.jpg',
    ),
    _OnboardingPage(
      title: 'Ready for the Outdoors',
      body:
          'Semua kebutuhan outdoor-mu tersedia. Mulai perjalananmu sekarang.',
      image: 'asset/onboarding-3.jpg',
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
    final size = MediaQuery.sizeOf(context);
    final maxImageHeight = size.height * 0.42;
    final maxImageWidth = size.width - AppSpacing.screen * 2;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (context, i) {
                final page = _pages[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screen,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: maxImageHeight,
                          maxWidth: maxImageWidth,
                        ),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            child: Image.asset(
                              page.image,
                              fit: BoxFit.cover,
                              frameBuilder:
                                  (context, child, frame, wasSynchronouslyLoaded) {
                                if (wasSynchronouslyLoaded || frame != null) {
                                  return child;
                                }
                                return Container(
                                  color: AppColors.lightGray,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.terrain_rounded,
                                    color: AppColors.gray,
                                    size: 48,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.lightGray,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.terrain_rounded,
                                    color: AppColors.gray,
                                    size: 48,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        page.body,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (dot) {
                          final active = dot == _index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.forest
                                  : AppColors.controlBorder,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: _index == _pages.length - 1
                            ? 'Mulai'
                            : 'Lanjut',
                        onPressed:
                            _index == _pages.length - 1 ? _finish : _next,
                      ),
                    ],
                  ),
                );
              },
            ),
            if (_index < _pages.length - 1)
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.screen,
                child: TextButton(
                  onPressed: _finish,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.gray,
                  ),
                  child: const Text('Lewati'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.image,
  });

  final String title;
  final String body;
  final String image;
}
