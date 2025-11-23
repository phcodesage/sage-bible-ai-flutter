import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Service
/// 
/// Handles Supabase initialization and provides access to the client.
/// This is a singleton service that should be initialized once at app startup.
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  /// Get singleton instance
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Initialize Supabase
  /// 
  /// Call this once in main() before runApp()
  /// 
  /// Example:
  /// ```dart
  /// await SupabaseService.initialize(
  ///   url: 'YOUR_SUPABASE_URL',
  ///   anonKey: 'YOUR_SUPABASE_ANON_KEY',
  /// );
  /// ```
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _client = Supabase.instance.client;
  }

  /// Get Supabase client
  /// 
  /// Throws an error if Supabase hasn't been initialized
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase has not been initialized. '
        'Call SupabaseService.initialize() in main() before using the client.',
      );
    }
    return _client!;
  }

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get auth state changes stream
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
