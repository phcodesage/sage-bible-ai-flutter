import 'package:sagebible/core/constants/app_constants.dart';
import 'package:sagebible/core/models/user_model.dart';
import 'package:sagebible/core/services/storage_service.dart';

/// Authentication Service
/// 
/// Handles all authentication operations.
/// In production, this would integrate with Firebase Auth, Supabase, or your backend API.
/// For now, it simulates authentication with local storage.
class AuthService {
  final StorageService _storageService;

  AuthService(this._storageService);

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    return _storageService.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  /// Get current user from storage
  Future<UserModel?> getCurrentUser() async {
    final isLoggedIn = await isAuthenticated();
    if (!isLoggedIn) return null;

    final userId = _storageService.getString(AppConstants.keyUserId);
    final email = _storageService.getString(AppConstants.keyUserEmail);
    final name = _storageService.getString(AppConstants.keyUserName);

    if (userId == null || email == null || name == null) {
      return null;
    }

    return UserModel(
      id: userId,
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );
  }

  /// Login with email and password
  /// 
  /// In production, this would make an API call to your backend.
  /// For demo purposes, it accepts any email/password combination.
  Future<UserModel> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

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

    // Create user (in production, this would come from your backend)
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: email.split('@')[0], // Use email prefix as name
      createdAt: DateTime.now(),
    );

    // Save to storage
    await _storageService.setBool(AppConstants.keyIsLoggedIn, true);
    await _storageService.setString(AppConstants.keyUserId, user.id);
    await _storageService.setString(AppConstants.keyUserEmail, user.email);
    await _storageService.setString(AppConstants.keyUserName, user.name);

    return user;
  }

  /// Register a new user
  /// 
  /// In production, this would create a new user in your backend.
  Future<UserModel> register(String name, String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

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

    // Create user (in production, this would come from your backend)
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );

    // Save to storage
    await _storageService.setBool(AppConstants.keyIsLoggedIn, true);
    await _storageService.setString(AppConstants.keyUserId, user.id);
    await _storageService.setString(AppConstants.keyUserEmail, user.email);
    await _storageService.setString(AppConstants.keyUserName, user.name);

    return user;
  }

  /// Logout current user
  Future<void> logout() async {
    await _storageService.remove(AppConstants.keyIsLoggedIn);
    await _storageService.remove(AppConstants.keyUserId);
    await _storageService.remove(AppConstants.keyUserEmail);
    await _storageService.remove(AppConstants.keyUserName);
  }
}
