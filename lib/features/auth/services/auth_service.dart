import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sagebible/core/config/google_config.dart';
import 'package:sagebible/core/constants/app_constants.dart';
import 'package:sagebible/core/models/user_model.dart';
import 'package:sagebible/core/services/storage_service.dart';
import 'package:sagebible/core/services/supabase_service.dart';

/// Authentication Service
/// 
/// Handles all authentication operations using Supabase.
/// Uses native Google Sign-In for mobile, OAuth for web.
class AuthService {
  final StorageService _storageService;
  final SupabaseClient _supabase = SupabaseService.client;
  
  // Google Sign-In for native mobile apps (Android/iOS)
  // serverClientId is the Web Client ID from Google Cloud Console
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: GoogleConfig.webClientId,
  );

  AuthService(this._storageService);

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    final session = _supabase.auth.currentSession;
    return session != null;
  }

  /// Get current user from Supabase
  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    // Try to get avatar from local storage first (for offline support)
    final cachedAvatar = await _storageService.getString(AppConstants.keyUserAvatar);
    
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['full_name'] ?? 
            user.userMetadata?['name'] ?? 
            user.email?.split('@')[0] ?? 
            'User',
      avatarUrl: user.userMetadata?['avatar_url'] ?? 
                 user.userMetadata?['picture'] ??
                 cachedAvatar,
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }

  /// Login with email and password using Supabase
  Future<UserModel> login(String email, String password) async {
    try {
      // Basic validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      if (!email.contains('@')) {
        throw Exception('Invalid email format');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Sign in with Supabase
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed');
      }

      final user = UserModel(
        id: response.user!.id,
        email: response.user!.email ?? email,
        name: response.user!.userMetadata?['full_name'] ?? email.split('@')[0],
        createdAt: DateTime.tryParse(response.user!.createdAt),
      );

      // Save to local storage for offline access
      await _storageService.setBool(AppConstants.keyIsLoggedIn, true);
      await _storageService.setString(AppConstants.keyUserId, user.id);
      await _storageService.setString(AppConstants.keyUserEmail, user.email);
      await _storageService.setString(AppConstants.keyUserName, user.name);

      return user;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Register a new user with Supabase
  Future<UserModel> register(String name, String email, String password) async {
    try {
      // Basic validation
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('All fields are required');
      }

      if (!email.contains('@')) {
        throw Exception('Invalid email format');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Sign up with Supabase
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
        },
        emailRedirectTo: null, // Disable email confirmation redirect
      );

      if (response.user == null) {
        throw Exception('Registration failed');
      }

      // Check if email confirmation is required
      if (response.session == null) {
        throw Exception(
          'Please check your email to confirm your account. '
          'If you don\'t see the email, check your spam folder or disable email confirmation in Supabase settings.',
        );
      }

      final user = UserModel(
        id: response.user!.id,
        email: response.user!.email ?? email,
        name: name,
        createdAt: DateTime.tryParse(response.user!.createdAt),
      );

      // Save to local storage
      await _storageService.setBool(AppConstants.keyIsLoggedIn, true);
      await _storageService.setString(AppConstants.keyUserId, user.id);
      await _storageService.setString(AppConstants.keyUserEmail, user.email);
      await _storageService.setString(AppConstants.keyUserName, user.name);

      return user;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Sign in with Google
  /// Uses native Google Sign-In for mobile, OAuth for web
  Future<UserModel> signInWithGoogle() async {
    try {
      // Use different methods based on platform
      if (kIsWeb) {
        return await _signInWithGoogleWeb();
      } else {
        return await _signInWithGoogleNative();
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  /// Native Google Sign-In for Android/iOS
  Future<UserModel> _signInWithGoogleNative() async {
    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
    if (googleUser == null) {
      throw Exception('Google sign-in cancelled');
    }

    // Get Google authentication tokens
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null || idToken == null) {
      throw Exception('Failed to get Google authentication tokens');
    }

    // Sign in to Supabase with Google ID token
    final response = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    if (response.user == null) {
      throw Exception('Failed to authenticate with Supabase');
    }

    final userModel = UserModel(
      id: response.user!.id,
      email: response.user!.email ?? googleUser.email,
      name: response.user!.userMetadata?['full_name'] ?? 
            response.user!.userMetadata?['name'] ?? 
            googleUser.displayName ?? 
            googleUser.email.split('@')[0],
      avatarUrl: response.user!.userMetadata?['avatar_url'] ?? 
                 response.user!.userMetadata?['picture'] ?? 
                 googleUser.photoUrl,
      createdAt: DateTime.tryParse(response.user!.createdAt),
    );

    // Save to local storage
    await _storageService.setBool(AppConstants.keyIsLoggedIn, true);
    await _storageService.setString(AppConstants.keyUserId, userModel.id);
    await _storageService.setString(AppConstants.keyUserEmail, userModel.email);
    await _storageService.setString(AppConstants.keyUserName, userModel.name);
    if (userModel.avatarUrl != null) {
      await _storageService.setString(AppConstants.keyUserAvatar, userModel.avatarUrl!);
    }

    return userModel;
  }

  /// Web OAuth Google Sign-In
  Future<UserModel> _signInWithGoogleWeb() async {
    // Use Supabase's OAuth flow for web
    final response = await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: null,
    );

    if (!response) {
      throw Exception('Google sign-in cancelled or failed');
    }

    // Wait for auth state to update
    await Future.delayed(const Duration(milliseconds: 500));

    final user = _supabase.auth.currentUser;
    
    if (user == null) {
      throw Exception('Google sign-in failed - no user returned');
    }

    final userModel = UserModel(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['full_name'] ?? 
            user.userMetadata?['name'] ?? 
            user.email?.split('@')[0] ?? 
            'User',
      avatarUrl: user.userMetadata?['avatar_url'] ?? 
                 user.userMetadata?['picture'],
      createdAt: DateTime.tryParse(user.createdAt),
    );

    // Save to local storage
    await _storageService.setBool(AppConstants.keyIsLoggedIn, true);
    await _storageService.setString(AppConstants.keyUserId, userModel.id);
    await _storageService.setString(AppConstants.keyUserEmail, userModel.email);
    await _storageService.setString(AppConstants.keyUserName, userModel.name);
    if (userModel.avatarUrl != null) {
      await _storageService.setString(AppConstants.keyUserAvatar, userModel.avatarUrl!);
    }

    return userModel;
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      // Sign out from Google (native only)
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      
      // Sign out from Supabase
      await _supabase.auth.signOut();
      
      // Clear local storage
      await _storageService.remove(AppConstants.keyIsLoggedIn);
      await _storageService.remove(AppConstants.keyUserId);
      await _storageService.remove(AppConstants.keyUserEmail);
      await _storageService.remove(AppConstants.keyUserName);
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
}
