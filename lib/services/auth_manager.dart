// lib/services/auth_manager.dart
import 'dart:convert';
import 'dart:io';

import 'package:app/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../features/auth/domain/entities/user_entity.dart';
import '../features/auth/presentation/cubit/google_login_cubit.dart';

class AuthManager {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _currentUserKey = 'currentUser';
  static const String _fcmTokenKey = 'fcm_token';

  // iOS secure storage configuration
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Cache variables for performance
  static String? _cachedToken;
  static String? _cachedRefreshToken;
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences for Android
  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Platform-specific storage methods
  static Future<String?> _readSecure(String key) async {
    if (Platform.isIOS) {
      return await _secureStorage.read(key: key);
    } else {
      // Android - use SharedPreferences
      final prefs = await _getPrefs();
      return prefs.getString(key);
    }
  }

  static Future<void> _writeSecure(String key, String value) async {
    if (Platform.isIOS) {
      await _secureStorage.write(key: key, value: value);
    } else {
      // Android - use SharedPreferences
      final prefs = await _getPrefs();
      await prefs.setString(key, value);
    }
  }

  static Future<void> _deleteSecure(String key) async {
    if (Platform.isIOS) {
      await _secureStorage.delete(key: key);
    } else {
      // Android - use SharedPreferences
      final prefs = await _getPrefs();
      await prefs.remove(key);
    }
  }

  // Get token (with caching for performance)
  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;

    _cachedToken = await _readSecure(_tokenKey);
    return _cachedToken;
  }

  // Set token
  static Future<void> setToken(String token) async {
    _cachedToken = token;
    await _writeSecure(_tokenKey, token);
  }

  // Clear token (for logout)
  static Future<void> clearToken() async {
    _cachedToken = null;
    await _deleteSecure(_tokenKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        // Call the logout API endpoint
        final response = await http.post(
          Uri.parse("$baseUrl/api/v1/auth/logout"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );

        // Log response for debugging if needed
        if (response.statusCode != 200) {
          debugPrint('Logout API failed with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Log the error but continue with local logout
      debugPrint('Error during logout: $e');
    } finally {
      // Always clear tokens locally
      await clearAllUserData();
    }
  }

  // Store refresh token securely
  static Future<void> setRefreshToken(String refreshToken) async {
    _cachedRefreshToken = refreshToken;
    await _writeSecure(_refreshTokenKey, refreshToken);
  }

  // Get refresh token securely
  static Future<String?> getRefreshToken() async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;

    _cachedRefreshToken = await _readSecure(_refreshTokenKey);
    return _cachedRefreshToken;
  }

  // Clear refresh token securely
  static Future<void> clearRefreshToken() async {
    _cachedRefreshToken = null;
    await _deleteSecure(_refreshTokenKey);
  }

  // Store FCM token
  static Future<void> setFCMToken(String fcmToken) async {
    await _writeSecure(_fcmTokenKey, fcmToken);
  }

  // Get FCM token
  static Future<String?> getFCMToken() async {
    return await _readSecure(_fcmTokenKey);
  }

  static Future<void> clearSecretKeys() async {
    UserEntity? user = await AuthManager.getCurrentUser();
    if (user != null) {
      await _deleteSecure('${user.id}_private_key');
    }
  }

  // Refresh token method
  static Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final fcmToken = await getFCMToken();
      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/auth/refresh"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken, "deviceId": fcmToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Update both tokens if provided
        if (data['access_token'] != null) {
          await setToken(data['access_token']);
        }
        if (data['refresh_token'] != null) {
          await setRefreshToken(data['refresh_token']);
        }
        await _fetchCurrentUser();

        return true;
      } else {
        // If refresh fails, clear tokens and return false
        await clearAllTokens();
        return false;
      }
    } catch (e) {
      // Error handling
      debugPrint('Error refreshing token: $e');
      await clearAllTokens();
      return false;
    }
  }

  // Helper method to clear all tokens
  static Future<void> clearAllTokens() async {
    await clearToken();
    await clearRefreshToken();
  }

  // Check if token is expired (basic check - you might want to implement JWT parsing)
  static Future<bool> isTokenExpired() async {
    final token = await getToken();
    if (token == null) return true;

    // You can implement JWT token expiration check here
    // For now, this is a placeholder
    return false;
  }

  // Auto-refresh token if needed
  static Future<String?> getValidToken() async {
    final token = await getToken();
    if (token == null) return null;

    // Check if token is expired and try to refresh
    if (await isTokenExpired()) {
      final refreshed = await refreshToken();
      if (refreshed) {
        return await getToken();
      } else {
        return null;
      }
    }

    return token;
  }

  static Future<UserEntity?> getCurrentUser() async {
    final userJson = await _readSecure(_currentUserKey);

    if (userJson != null) {
      try {
        // Convert the JSON string back to a UserEntity object
        return UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        debugPrint('Error parsing stored user data: $e');
        // Clear corrupted data
        await clearCurrentUser();
        return null;
      }
    }

    return null;
  }

  static Future<void> clearCurrentUser() async {
    await _deleteSecure(_currentUserKey);
  }

  static Future<void> _fetchCurrentUser() async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/user/profile"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final UserEntity user = UserModel.fromJson(jsonDecode(response.body));
        await _writeSecure(_currentUserKey, jsonEncode(user));
      } else {
        if (response.statusCode == 401) {
          await AuthManager.logout();
        }
        throw Exception('Failed to fetch current user: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching current user: $e');
      rethrow;
    }
  }

  // Store user private key
  static Future<void> setUserPrivateKey(
    String userId,
    String privateKey,
  ) async {
    await _writeSecure('${userId}_private_key', privateKey);
  }

  // Get user private key
  static Future<String?> getUserPrivateKey(String userId) async {
    return await _readSecure('${userId}_private_key');
  }

  // Clear all user data (useful for complete logout/reset)
  static Future<void> clearAllUserData() async {
    await clearToken();
    await clearRefreshToken();
    await clearCurrentUser();
    // await clearSecretKeys();

    // Sign out from Google if currently signed in
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    // Clear cache
    _cachedToken = null;
    _cachedRefreshToken = null;
  }
}
