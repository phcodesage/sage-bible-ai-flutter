import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sagebible/core/constants/app_constants.dart';
import 'package:sagebible/core/theme/app_theme.dart';
import 'package:sagebible/features/auth/providers/auth_provider.dart';
import 'package:sagebible/features/onboarding/providers/onboarding_provider.dart';

/// Splash Screen
/// 
/// Displays app logo with animation while checking onboarding and auth status.
/// After initialization, automatically navigates to appropriate screen.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize app and check onboarding + authentication status
  Future<void> _initializeApp() async {
    // Wait minimum splash duration for smooth UX
    await Future.delayed(AppConstants.splashDuration);
    
    if (!mounted) return;
    
    try {
      // Check onboarding status
      await ref.read(onboardingProvider.notifier).checkOnboardingStatus();
      final hasCompletedOnboarding = ref.read(onboardingProvider).hasCompletedOnboarding;
      
      if (!hasCompletedOnboarding) {
        // First time user - show onboarding
        if (mounted) context.go('/onboarding');
        return;
      }
      
      // Check authentication status
      await ref.read(authProvider.notifier).checkAuthStatus();
      final isAuthenticated = ref.read(authProvider).isAuthenticated;
      
      // Go to home (works for both authenticated and guest users)
      if (mounted) context.go('/home');
      
    } catch (e) {
      // If there's an error, go to onboarding
      if (mounted) context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo - Your Custom Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/icon.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to icon if image fails to load
                    return Container(
                      color: AppTheme.surfaceColor,
                      child: Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 60,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
            .animate()
            .fadeIn(
              duration: AppConstants.fadeInDuration,
              curve: Curves.easeOut,
            )
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: AppConstants.fadeInDuration,
              curve: Curves.easeOut,
            ),
            
            const SizedBox(height: 24),
            
            // App Name
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            )
            .animate()
            .fadeIn(
              delay: 200.ms,
              duration: AppConstants.fadeInDuration,
              curve: Curves.easeOut,
            )
            .slideY(
              begin: 0.3,
              end: 0,
              delay: 200.ms,
              duration: AppConstants.fadeInDuration,
              curve: Curves.easeOut,
            ),
            
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              'Your Daily Spiritual Companion',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            )
            .animate()
            .fadeIn(
              delay: 400.ms,
              duration: AppConstants.fadeInDuration,
              curve: Curves.easeOut,
            ),
            
            const SizedBox(height: 48),
            
            // Loading Indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor.withOpacity(0.5),
                ),
              ),
            )
            .animate()
            .fadeIn(
              delay: 600.ms,
              duration: 500.ms,
            ),
          ],
        ),
      ),
    );
  }
}
