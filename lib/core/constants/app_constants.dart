/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'SageBible';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserEmail = 'user_email';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  
  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration fadeInDuration = Duration(milliseconds: 800);
  
  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
}
