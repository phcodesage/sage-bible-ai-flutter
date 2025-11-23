import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sagebible/core/constants/app_constants.dart';
import 'package:sagebible/core/router/app_router.dart';
import 'package:sagebible/core/theme/app_theme.dart';
import 'package:sagebible/features/onboarding/models/onboarding_page_model.dart';
import 'package:sagebible/features/onboarding/providers/onboarding_provider.dart';

/// Onboarding Screen
/// 
/// Modern swipeable onboarding flow that introduces app features.
/// Users can skip to use offline or sign in for community features.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<OnboardingPageModel> _pages = OnboardingData.pages;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Complete onboarding and navigate to home (skip sign in)
  Future<void> _completeOnboarding() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go(AppRouter.home);
    }
  }

  /// Complete onboarding and navigate to login
  Future<void> _completeOnboardingWithSignIn() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go(AppRouter.login);
    }
  }

  /// Go to next page
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip button
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  // Skip button
                  if (!isLastPage)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text('Skip'),
                    ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(page: _pages[index]);
                },
              ),
            ),

            // Bottom Section: Indicators and Buttons
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _PageIndicator(
                        isActive: index == _currentPage,
                        color: _pages[index].color,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Buttons
                  if (isLastPage)
                    // Last page: Show both options
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Sign In button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _completeOnboardingWithSignIn,
                            child: const Text('Sign In for Full Experience'),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Continue without sign in
                        SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _completeOnboarding,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppTheme.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Continue Without Sign In'),
                          ),
                        ),
                      ],
                    )
                  else
                    // Other pages: Show Next button
                    SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        child: const Text('Next'),
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

/// Individual Onboarding Page
class _OnboardingPage extends StatelessWidget {
  final OnboardingPageModel page;

  const _OnboardingPage({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 70,
              color: page.color,
            ),
          )
          .animate()
          .fadeIn(duration: 600.ms)
          .scale(begin: const Offset(0.8, 0.8)),

          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: page.color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          )
          .animate()
          .fadeIn(delay: 200.ms, duration: 600.ms)
          .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          )
          .animate()
          .fadeIn(delay: 400.ms, duration: 600.ms),
        ],
      ),
    );
  }
}

/// Page Indicator Dot
class _PageIndicator extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _PageIndicator({
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? color : AppTheme.textLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
