import 'package:shared_preferences/shared_preferences.dart';

/// Storage Service
/// 
/// Handles all local storage operations using SharedPreferences.
/// This is a singleton service to ensure consistent access to storage.
class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  // Private constructor
  StorageService._();

  /// Get singleton instance
  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// Save a string value
  Future<bool> setString(String key, String value) async {
    return await _preferences!.setString(key, value);
  }

  /// Get a string value
  String? getString(String key) {
    return _preferences!.getString(key);
  }

  /// Save a boolean value
  Future<bool> setBool(String key, bool value) async {
    return await _preferences!.setBool(key, value);
  }

  /// Get a boolean value
  bool? getBool(String key) {
    return _preferences!.getBool(key);
  }

  /// Save an integer value
  Future<bool> setInt(String key, int value) async {
    return await _preferences!.setInt(key, value);
  }

  /// Get an integer value
  int? getInt(String key) {
    return _preferences!.getInt(key);
  }

  /// Remove a value
  Future<bool> remove(String key) async {
    return await _preferences!.remove(key);
  }

  /// Clear all values
  Future<bool> clear() async {
    return await _preferences!.clear();
  }

  /// Check if a key exists
  bool containsKey(String key) {
    return _preferences!.containsKey(key);
  }
}
