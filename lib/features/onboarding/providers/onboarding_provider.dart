import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagebible/core/services/storage_service.dart';
import 'package:sagebible/features/auth/providers/auth_provider.dart';

/// Onboarding State
class OnboardingState {
  final bool hasCompletedOnboarding;
  final bool isLoading;

  const OnboardingState({
    this.hasCompletedOnboarding = false,
    this.isLoading = false,
  });

  OnboardingState copyWith({
    bool? hasCompletedOnboarding,
    bool? isLoading,
  }) {
    return OnboardingState(
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Onboarding Notifier
/// 
/// Manages onboarding state - whether user has completed onboarding.
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final StorageService _storageService;
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  OnboardingNotifier(this._storageService) : super(const OnboardingState());

  /// Check if user has completed onboarding
  Future<void> checkOnboardingStatus() async {
    state = state.copyWith(isLoading: true);
    
    final hasCompleted = _storageService.getBool(_keyOnboardingCompleted) ?? false;
    
    state = state.copyWith(
      hasCompletedOnboarding: hasCompleted,
      isLoading: false,
    );
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    await _storageService.setBool(_keyOnboardingCompleted, true);
    state = state.copyWith(hasCompletedOnboarding: true);
  }

  /// Reset onboarding (for testing)
  Future<void> resetOnboarding() async {
    await _storageService.remove(_keyOnboardingCompleted);
    state = state.copyWith(hasCompletedOnboarding: false);
  }
}

/// Provider for OnboardingNotifier
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return OnboardingNotifier(storageService);
});
