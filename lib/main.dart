import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagebible/core/config/supabase_config.dart';
import 'package:sagebible/core/providers/theme_provider.dart';
import 'package:sagebible/core/router/app_router.dart';
import 'package:sagebible/core/services/storage_service.dart';
import 'package:sagebible/core/services/supabase_service.dart';
import 'package:sagebible/core/theme/app_theme.dart';
import 'package:sagebible/features/auth/providers/auth_provider.dart';

/// Main Entry Point
/// 
/// Initializes the app with:
/// - Supabase for backend services
/// - Riverpod for state management
/// - StorageService for local persistence
/// - GoRouter for navigation
/// - Custom theme
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  if (SupabaseConfig.isConfigured) {
    await SupabaseService.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  } else {
    // Show warning if Supabase is not configured
    debugPrint(
      '⚠️ WARNING: Supabase is not configured. '
      'Please update lib/core/config/supabase_config.dart with your credentials.',
    );
  }

  // Initialize StorageService
  final storageService = await StorageService.getInstance();

  // Set preferred orientations (portrait only for better UX)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Run app with Riverpod
  runApp(
    ProviderScope(
      overrides: [
        // Override StorageService provider with initialized instance
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const SageBibleApp(),
    ),
  );
}

/// SageBible App Widget
/// 
/// Root widget that configures MaterialApp with:
/// - GoRouter for navigation
/// - Custom theme
/// - App-wide settings
class SageBibleApp extends ConsumerWidget {
  const SageBibleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get router instance
    final router = ref.watch(goRouterProvider);
    
    // Watch theme mode
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      // App Configuration
      title: 'SageBible',
      debugShowCheckedModeBanner: false,

      // Theme - disable animations to prevent interpolation errors
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      themeAnimationDuration: Duration.zero, // Instant theme switch
      themeAnimationCurve: Curves.linear,

      // Router Configuration
      routerConfig: router,

      // Builder for additional configuration
      builder: (context, child) {
        // Wrap in MediaQuery to prevent text style inheritance issues
        return MediaQuery(
          data: MediaQuery.of(context),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
