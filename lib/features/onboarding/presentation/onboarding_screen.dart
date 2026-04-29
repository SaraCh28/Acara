import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/branded_logo.dart';
import '../../../services/app_preferences_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Discover events near you',
      'text':
          'Explore concerts, art nights, and local gatherings matched to your city.',
      "image":
          "https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=1200&q=80",
    },
    {
      'title': 'Build a personalized feed',
      'text':
          'Choose what you care about and get recommendations that improve over time.',
      "image":
          "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80",
    },
    {
      'title': 'Book tickets in minutes',
      'text':
          'Pick ticket types, pay securely, and keep every booking in one place.',
      "image":
          "https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=1200&q=80",
    },
  ];

  Future<void> _finishOnboarding() async {
    await ref.read(appPreferencesProvider.notifier).markOnboardingSeen();
    if (!mounted) {
      return;
    }
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (value) {
              setState(() {
                _currentPage = value;
              });
            },
            itemCount: onboardingData.length,
            itemBuilder: (context, index) => OnboardingContent(
              image: onboardingData[index]["image"]!,
              title: onboardingData[index]['title']!,
              text: onboardingData[index]["text"]!,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: AppConstants.paddingLarge,
            child: const BrandedLogo(
              size: 46,
              showWordmark: false,
            ).animate().fadeIn(duration: 350.ms),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: AppConstants.paddingLarge,
            child: TextButton(
              onPressed: _finishOnboarding,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.14),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                ),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            left: AppConstants.paddingLarge,
            right: AppConstants.paddingLarge,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      onboardingData.length,
                      (index) => buildDot(index: index),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == onboardingData.length - 1) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(132, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _currentPage == onboardingData.length - 1
                          ? 'Get Started'
                          : 'Next',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AnimatedContainer buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.primary
            : AppColors.primaryLight.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  const OnboardingContent({
    super.key,
    required this.title,
    required this.text,
    required this.image,
  });
  final String title;
  final String text;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            image,
            fit: BoxFit.cover,
            width: double.infinity,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: const Center(
                  child: Icon(Icons.image_not_supported_rounded, color: Colors.white, size: 64),
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.48),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 88),
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 380.ms).slideY(begin: 0.08),
        ),
      ],
    );
  }
}
