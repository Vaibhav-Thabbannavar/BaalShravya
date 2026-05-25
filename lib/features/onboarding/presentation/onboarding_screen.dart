import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import 'package:baalshravya_app/core/constants/app_colors.dart';
import 'package:baalshravya_app/core/constants/app_routes.dart';

// data class for one onboarding slide
class _OnboardingData {
  final String emoji;
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) description;
  final Color color;

  const _OnboardingData({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  // controls which slide is currently visible
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // slide content — title and description come from l10n
  final List<_OnboardingData> _slides = [
    _OnboardingData(
      emoji: '👶',
      title: (l10n) => l10n.onboarding1Title,
      description: (l10n) => l10n.onboarding1Desc,
      color: const Color(0xFFE0F7FA),
    ),
    _OnboardingData(
      emoji: '📋',
      title: (l10n) => l10n.onboarding2Title,
      description: (l10n) => l10n.onboarding2Desc,
      color: const Color(0xFFFFF3E0),
    ),
    _OnboardingData(
      emoji: '🔊',
      title: (l10n) => l10n.onboarding3Title,
      description: (l10n) => l10n.onboarding3Desc,
      color: const Color(0xFFE8F5E9),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // mark onboarding as seen and go to login
  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    // save a flag so next launch skips onboarding
    await prefs.setBool('onboarding_seen', true);
    if (mounted) context.go(AppRoutes.login);
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // skip button — top right
            // only shown on first two slides
            Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                opacity: isLastPage ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: TextButton(
                  onPressed: isLastPage ? null : _finishOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            // slides take up most of the screen
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _OnboardingSlide(
                    data: _slides[index],
                    l10n: l10n,
                  );
                },
              ),
            ),
            // dots + button at the bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // next or get started button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(
                        isLastPage ? l10n.getStarted : l10n.next,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// one individual slide
class _OnboardingSlide extends StatelessWidget {
  final _OnboardingData data;
  final AppLocalizations l10n;

  const _OnboardingSlide({
    required this.data,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // emoji illustration inside a colored circle
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                data.emoji,
                style: const TextStyle(fontSize: 72),
              ),
            ),
          ),
          const SizedBox(height: 40),
          // title
          Text(
            data.title(l10n),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          // description
          Text(
            data.description(l10n),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
